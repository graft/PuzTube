class CreateWorkspaces < ActiveRecord::Migration
  def self.up
    create_table :workspaces do |t|
      t.string :content
      t.string :thread_type
      t.integer :thread_id

      t.timestamps
    end
  end

  def self.down
    drop_table :workspaces
  end
end
