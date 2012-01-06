class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :puzzle_id
      t.integer :user_id
      t.integer :hunt_id
      t.string :task

      t.timestamps
    end
    add_index :activities, :puzzle_id, :name => :activities_puzzle_id_idx
    add_index :activities, :user_id, :name => :activities_user_id_idx
    add_index :activities, :hunt_id, :name => :activities_hunt_id_idx
  end

  def self.down
    drop_table :activities
  end
end
