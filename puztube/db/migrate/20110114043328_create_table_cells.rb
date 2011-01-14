class CreateTableCells < ActiveRecord::Migration
  def self.up
    create_table :table_cells do |t|
      t.string :contents
      t.integer :cell_id
      t.integer :table_id

      t.timestamps
    end
  end

  def self.down
    drop_table :table_cells
  end
end
