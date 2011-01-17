class AddHiddenToRound < ActiveRecord::Migration
  def self.up
    add_column :rounds, :hidden, :boolean
  end

  def self.down
    remove_column :rounds, :hidden
  end
end
