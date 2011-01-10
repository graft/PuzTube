class AddWorkspaceidToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :workspace_id, :integer
  end

  def self.down
    remove_column :assets, :workspace_id
  end
end
