class AddReadToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :read, :boolean, :default => false
  end

  def self.down
    remove_column :requests, :read
  end
end
