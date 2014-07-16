class Country
  include Mongoid::Document
  
  field :year, type: Integer
  field :country, type: String
  field :words, type: Array
  field :y, type: Float
  field :x, type: Float
end