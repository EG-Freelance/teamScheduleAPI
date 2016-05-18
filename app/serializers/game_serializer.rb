class GameSerializer < ActiveModel::Serializer
  belongs_to :schedule
  attributes :date, :home, :opponent
end
