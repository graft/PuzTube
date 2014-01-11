class AddWorkspaceTypeToWorkspace < ActiveRecord::Migration
  def change
    add_column :workspaces, :workspace_type, :string
  end
end
