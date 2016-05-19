class TeamSerializer < ActiveModel::Serializer
  has_many :games
  
  attributes :sport, :full_name, :espn_abbv, :yahoo_abbv
end
