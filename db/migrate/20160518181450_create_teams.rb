class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :sport
      t.string :full_name
      t.string :espn_abbv
      t.string :yahoo_abbv

      t.timestamps null: false
    end
  end
end
