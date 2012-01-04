class AddHuntidToRound < ActiveRecord::Migration
  def self.up
    add_column :rounds, :hunt_id, :integer
  end

  def self.down
    remove_column :rounds, :hunt_id
  end
end
