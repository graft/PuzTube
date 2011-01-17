class AddPriorityToWorkspace < ActiveRecord::Migration
  def self.up
    add_column :workspaces, :priority, :string
  end

  def self.down
    remove_column :workspaces, :priority
  end
end
