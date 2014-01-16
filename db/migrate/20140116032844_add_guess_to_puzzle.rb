class AddGuessToPuzzle < ActiveRecord::Migration
  def change
    add_column :puzzles, :guess, :string
  end
end
