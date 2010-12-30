class CreatePuzzles < ActiveRecord::Migration
  def self.up
    create_table :puzzles do |t|
      t.string :name
      t.string :hint
      t.string :captain
      t.string :answer
      t.boolean :meta
      t.integer :round_id
      t.string :status
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :puzzles
  end
end
