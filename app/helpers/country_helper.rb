module CountryHelper

  def get_country(year,country)
    c = Country.find_by(year: year, country: country)

    if c.nil?
      i = 0
      searches = nil
      data = nil
      while searches.nil? && data != "error" do
        puts "#{year} - #{country} - FETCH PAGE #{i}"
        data = search_words(year, country, i)["data"]
        if data != "error"
          list = data["chartList"]
          searches = get_searches_list(list, data["lastPage"])
          i += 1
        end
      end

      if data == "error"
        return nil
      end

      words = searches.collect { |e| e["title"] }
      
      c = Country.new
      c.year = year
      c.country = country
      c.words = words

      c.save
    end

    return c
  end

  def get_searches_list(list, last_page)
    list.each do |e|
      if !e["trendingChart"].nil?
        if e["trendingChart"]["visibleName"] == "Searches"
          return e["trendingChart"]["entityList"]
        end
        if last_page
          return e["trendingChart"]["entityList"]
        end
      end
    end
    if last_page
      return list[0]["topChart"]["entityList"]
    end
    return nil
  end

  def search_words(year, country, page)
    parameters = {ajax:1,geo:country,date:year,cat:"",tn:6*page}
    response = Unirest.post "http://www.google.com.ar/trends/topcharts/category", parameters: parameters
    puts response.to_json
    if response.code == 404
      return {"data" => "error"}
    else
      return response.body
    end
  end

end