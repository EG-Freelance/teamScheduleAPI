class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.datetime :date
      t.boolean :home
      t.string :opponent

      t.timestamps null: false
    end
  end
end
