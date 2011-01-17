class AddPriorityToRound < ActiveRecord::Migration
  def self.up
    add_column :rounds, :priority, :string
  end

  def self.down
    remove_column :rounds, :priority
  end
end
