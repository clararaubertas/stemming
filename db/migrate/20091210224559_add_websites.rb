class AddWebsites < ActiveRecord::Migration
  def self.up
    add_column :users, :websites, :text
  end

  def self.down
    remove_column :users, :websites
  end
end
