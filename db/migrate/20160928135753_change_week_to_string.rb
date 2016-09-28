class ChangeWeekToString < ActiveRecord::Migration
  def change
    change_column :games, :week, :string
  end
end
