class AddTitleToWorkspace < ActiveRecord::Migration
  def self.up
    add_column :workspaces, :title, :string
  end

  def self.down
    remove_column :workspaces, :title
  end
end
