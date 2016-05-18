class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.belongs_to :schedule
      t.datetime :date
      t.boolean :home
      t.string :opponent

      t.timestamps null: false
    end
  end
end
