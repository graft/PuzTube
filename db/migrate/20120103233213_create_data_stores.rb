class CreateDataStores < ActiveRecord::Migration
  def self.up
    create_table :data_stores do |t|
      t.string :key
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :data_stores
  end
end
