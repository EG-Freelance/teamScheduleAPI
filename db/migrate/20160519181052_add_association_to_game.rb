class AddAssociationToGame < ActiveRecord::Migration
  def change
    add_reference :games, :team, index: true
    remove_column :games, :schedule_id
  end
end
