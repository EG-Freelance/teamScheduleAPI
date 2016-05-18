class ScheduleSerializer < ActiveModel::Serializer
  belongs_to :team
  has_many :games, dependent: :destroy
  
  attributes :season
end
