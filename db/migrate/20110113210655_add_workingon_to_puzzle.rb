class AddWorkingonToPuzzle < ActiveRecord::Migration
  def self.up
    add_column :puzzles, :workers, :string
  end

  def self.down
    remove_column :puzzles, :workers
  end
end
