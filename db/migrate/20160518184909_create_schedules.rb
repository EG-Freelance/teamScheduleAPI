class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.belongs_to :team
      t.string :season

      t.timestamps null: false
    end
  end
end
