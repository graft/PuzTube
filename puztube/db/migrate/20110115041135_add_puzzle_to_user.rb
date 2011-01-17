class AddPuzzleToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :puzzle_id, :integer
  end

  def self.down
    remove_column :users, :puzzle_id
  end
end
