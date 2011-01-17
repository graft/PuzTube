class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :email
      t.string :image
      t.string :info
      t.string :activity
      t.datetime :lastactive

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
