class AddEditorToWorkspace < ActiveRecord::Migration
  def self.up
    add_column :workspaces, :editor, :string
  end

  def self.down
    remove_column :workspaces, :editor
  end
end
