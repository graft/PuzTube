class AddIndexToMultiple < ActiveRecord::Migration
  def self.up
    add_index :chats, :chat_id, :name => :chat_id_idx
    add_index :chats, :created_at, :name => :created_at_idx
    add_index :puzzles, :round_id, :name => :round_id_idx
    add_index :rounds, :hunt_id, :name => :hunt_id_idx
    add_index :users, :login, :name => :login_idx
    add_index :workspaces, :thread_type, :name => :thread_type_idx
    add_index :workspaces, :thread_id, :name => :thread_id_idx
  end

  def self.down
    remove_index :chats, :name => :chat_id_idx
    remove_index :chats, :name => :created_at_idx
    remove_index :puzzles, :name => :round_id_idx
    remove_index :rounds, :name => :hunt_id_idx
    remove_index :users, :name => :login_idx
    remove_index :workspaces, :name => :thread_type_idx
    remove_index :workspaces, :name => :thread_id_idx
  end

end
