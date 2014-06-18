module ColorHelper
	require 'flickraw'
  require 'mini_magick'
	require 'chunky_png'

	def find_color(word)
    puts "Buscar  FOTO"

    FlickRaw.api_key="d87f457e6018a2dabe55fae4dd9f3adc"
    FlickRaw.shared_secret="6f33c141e4bfc959 "

		list   = flickr.photos.search(:text => word)

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
      model.color = p[0,0].to_s(16)
      model.save
    end

    return model
  end

end