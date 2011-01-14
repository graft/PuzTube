class AddContentToTable < ActiveRecord::Migration
  def self.up
    add_column :tables, :content, :string
  end

  def self.down
    remove_column :tables, :content
  end
end
