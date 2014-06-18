class Word
  include Mongoid::Document
  
  field :word, type: String
  field :color, type: String
  field :photos, type: Array, default: []

end