class Schedule < ActiveRecord::Base
  belongs_to :team
  has_many :games, dependent: :destroy
end
