class RemoveRowsFromTable < ActiveRecord::Migration
  def self.up
    remove_column :tables, :rows
    add_column :tables, :rows, :string
  end

  def self.down
    remove_column :tables, :rows
  end
end
