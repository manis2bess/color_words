class Photo
  include Mongoid::Document
  
  field :url, type: String
  field :id, type: String
  field :color, type: String
  
end