class TeamSerializer < ActiveModel::Serializer
  has_many :schedules
  has_many :games, through: :schedules
  
  attributes :id, :sport, :full_name, :espn_abbv, :yahoo_abbv
end
