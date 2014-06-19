module ColorHelper
	require 'flickraw'
  require 'mini_magick'
	require 'chunky_png'

	def find_color(word)
    puts "Buscar  FOTO"

    FlickRaw.api_key="d87f457e6018a2dabe55fae4dd9f3adc"
    FlickRaw.shared_secret="6f33c141e4bfc959"

		list   = flickr.photos.search(:sort => "relevance", :text => word)

    puts list.to_json

    id     = list[0].id
    secret = list[0].secret
    
    photo = get_photo(id)

    return photo.color
	end

  def get_photo(id)

    model= Photo.find_by(id: id)
    
    if model.nil?
      sizes = flickr.photos.getSizes :photo_id => id
      photo = sizes.select { |p| p["label"] == "Medium" }[0]

      puts photo.to_json

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

    puts model.to_json

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

      puts "r = #{red} - g = #{green} - b = #{blue}"

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

      puts "c = #{c} - r = #{red} - g = #{green} - b = #{blue} - rgb = #{rgb}"
    end

    c = dic.sort_by {|k,v| v }.last

    puts dic

    puts "------------adasd---------"
    puts c

    return c[0]

  end

end