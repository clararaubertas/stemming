class AddLatLong < ActiveRecord::Migration
  def self.up
    add_column :users, :lat, :float
    add_column :users, :lng, :float
  end

  def self.down
    remove_column :users, :lat
    remove_column :users, :lng
  end
end
