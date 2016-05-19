class GameSerializer < ActiveModel::Serializer
  belongs_to :team
  
  attributes :season, :date, :home, :opponent
end
