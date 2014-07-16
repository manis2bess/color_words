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
    w = Word.find_by(word: word)
    
    if w.nil?
      color = find_color(word)
      w = Word.new
      w.word = word
      w.color = color
      w.save
    end

    if w.color.nil?
      return nil
    end

    return w
  end

	def find_color(word)
    puts "Buscar  FOTO - #{word}"

    if word == "0"
      return nil
    end

    FlickRaw.api_key="d87f457e6018a2dabe55fae4dd9f3adc"
    FlickRaw.shared_secret="6f33c141e4bfc959"

		list   = flickr.photos.search(:sort => "relevance", :text => word)

    #puts list.to_json

    if list.length > 0
      id     = list[0].id
      secret = list[0].secret
      
      photo = get_photo(id)

      if photo
        return photo.color
      else
        return nil
      end
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
      #puts photo.to_json

      url = photo["source"]
      i = MiniMagick::Image.open(url)

      i.format('png')

      p = ChunkyPNG::Image.from_io(StringIO.new(i.to_blob))

      
      model = Photo.new
      model.id = id
      model.url = url
      model.color = montecarlo(p).to_s(16)
      model.save
    end

    #puts model.to_json

    return model
  end
  def montecarlo(photo)
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

      #puts "r = #{red} - g = #{green} - b = #{blue}"

      precision = 20

      blue = (blue.to_f/precision).floor()*precision
      green = (green.to_f/precision).floor()*precision
      red = (red.to_f/precision).floor()*precision

      #c = (red*(256^2))+(green*256)+blue
      rgb = red
      rgb = (rgb << 8) + green
      rgb = (rgb << 8) + blue
      
      dic[rgb] ||= 0
      dic[rgb] = dic[rgb] + 1

      #puts "c = #{c} - r = #{red} - g = #{green} - b = #{blue} - rgb = #{rgb}"
    end

    c = dic.sort_by {|k,v| v }.last

    #puts dic

    #puts "------------adasd---------"
    #puts c

    return c[0]

  end

  def normalize(query)
    nquery = query.strip
        nquery = UnicodeUtils.upcase nquery
        nquery = I18n.transliterate(nquery)
        nquery = nquery.gsub(/[^a-zA-Z0-9\-]/," ") 
        nquery = nquery.gsub("-"," ")
        nquery = nquery.strip
        return nquery
  end


end