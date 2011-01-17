class AddWronganswerToPuzzle < ActiveRecord::Migration
  def self.up
    add_column :puzzles, :wrong_answer, :string
  end

  def self.down
    remove_column :puzzles, :wrong_answer
  end
end
