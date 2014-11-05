module ColorHelper
	require 'flickraw'
  require 'mini_magick'
	require 'chunky_png'

  def get_words(words)
    ws = []
    words.each do |q|
      q = normalize(q)
      q.split(" ").each do |w|
        ws << find_word(w)
      end
    end

    return ws.compact
  end

  def find_word(word)
    @gdic = {}
    w = Word.find_by(word: word)
    
    if w.nil?
      photos = find_photos(word)
        w = Word.new
        w.word = word
        w.photos = photos
        if @gdic.size > 0
          w.color = @gdic.sort_by {|k,v| v }.last[0].to_i.to_s(16)
        else
          w.color = nil
        end
        w.save
    end

    if w.color.nil?
      return nil
    end

    return w
  end

	def find_photos(word)
    puts "Buscar  FOTO - #{word}"

    if word == "0"
      return nil
    end

    FlickRaw.api_key="d87f457e6018a2dabe55fae4dd9f3adc"
    FlickRaw.shared_secret="6f33c141e4bfc959"

    FlickRaw.check_certificate = false
  	list   = flickr.photos.search(:sort => "relevance", :text => word)

    #puts list.to_json

    if list.length > 0
      max = 1
      max = list.length < max ? list.length-1 : max-1

      photos = []
      (0..max).each do |i|
        id     = list[i].id
        secret = list[i].secret
        
        photo = get_photo(id)

        if photo
          photo.histogram.each do |rgb, v|
            @gdic[rgb] ||= 0.to_f
            @gdic[rgb] = @gdic[rgb] + v
          end
          photos << {id: photo.id, url: photo.url, color: photo.color}
        end
      end
      return photos
    else
      return nil
    end
	end

  def get_photo(id)
    puts id

    model= Photo.find_by(id: id)
    
    if model.nil?
      begin
        sizes = flickr.photos.getSizes :photo_id => id
      rescue
        return nil
      end
      photo = sizes.select { |p| p["label"] == "Medium" }[0]

      if photo.nil?
        photo = sizes[sizes.length-1]
      end
      
      url = photo["source"]
      puts url
      i = MiniMagick::Image.open(url)

      i.format('png')

      p = ChunkyPNG::Image.from_io(StringIO.new(i.to_blob))

      histogram = montecarlo(p)
      color = histogram.sort_by {|k,v| v }.last
      color = color[0]

      model = Photo.new
      model.id = id
      model.url = url
      model.color = color.to_s(16)
      model.histogram = histogram
      model.save
    end

    #puts model.to_json

    return model
  end
  def montecarlo(photo)
    @gdic ||= {}
    dic = {}
    (0..999).each do |i| 
      x = rand(photo.width).floor
      y = rand(photo.height).floor
      c = photo[x,y]

#      blue = c % 256
#      c = (c - blue) / 256
#      green = c % 256
#      c = (c - green) / 256
#      red = c
      a =  c & 255
      blue = (c >> 8) & 255
      green = (c >> 16) & 255
      red =   (c >> 24) & 255

      #brightness = ((red.to_f/255) * 0.299) + ((green.to_f/255) * 0.587) + ((blue.to_f/255) * 0.114)
      rf = red.to_f/255
      gf = green.to_f/255
      bf = blue.to_f/255
      
      coloritud = ((rf-gf).abs + (rf-bf).abs + (gf-bf).abs) / 3
      #puts "r = #{red} - g = #{green} - b = #{blue}"

      precision = 20

      blue = (blue.to_f/precision).floor()*precision
      green = (green.to_f/precision).floor()*precision
      red = (red.to_f/precision).floor()*precision

      #c = (red*(256^2))+(green*256)+blue
      rgb = red
      rgb = (rgb << 8) + green
      rgb = (rgb << 8) + blue
      
      dic[rgb] ||= 0.to_f
      dic[rgb] = dic[rgb] + coloritud

      @gdic[rgb] ||= 0.to_f
      @gdic[rgb] = @gdic[rgb] + coloritud


      #puts "c = #{c} - r = #{red} - g = #{green} - b = #{blue} - rgb = #{rgb}"
    end


    return dic

  end

  def normalize(query)
    nquery = query.strip
        nquery = UnicodeUtils.upcase nquery
        #nquery = I18n.transliterate(nquery)
        #nquery = nquery.gsub(/[^a-zA-Z0-9\-]/," ") 
        nquery = nquery.gsub("-"," ")
        nquery = nquery.strip
        return nquery
  end


end