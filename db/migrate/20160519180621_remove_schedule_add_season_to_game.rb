class RemoveScheduleAddSeasonToGame < ActiveRecord::Migration
  def change
    drop_table :schedules
    add_column :games, :season, :string
  end
end
