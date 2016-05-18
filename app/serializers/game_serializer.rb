class GameSerializer < ActiveModel::Serializer
  belongs_to :schedule
  attributes :id, :date, :home, :opponent
end
