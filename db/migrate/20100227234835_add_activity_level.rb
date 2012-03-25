class AddActivityLevel < ActiveRecord::Migration
  def self.up
    add_column :users, :activity_level, :int
  end

  def self.down
    remove_column :users, :activity_level
  end

end
