class AddPriorityToPuzzle < ActiveRecord::Migration
  def self.up
    add_column :puzzles, :priority, :string
  end

  def self.down
    remove_column :puzzles, :priority
  end
end
