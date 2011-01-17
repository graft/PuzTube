class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :tables do |t|
      t.string :priority
      t.string :title
      t.string :editor
      t.integer :rows
      t.integer :cols
      t.integer :thread_id
      t.string :thread_type

      t.timestamps
    end
  end

  def self.down
    drop_table :tables
  end
end
