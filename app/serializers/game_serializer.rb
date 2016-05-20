class GameSerializer < ActiveModel::Serializer
  belongs_to :team
  
  attributes :season, :week, :date, :home, :opponent
end
