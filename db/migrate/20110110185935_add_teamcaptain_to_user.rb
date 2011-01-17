class AddTeamcaptainToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :team_captain, :boolean
  end

  def self.down
    remove_column :users, :team_captain
  end
end
