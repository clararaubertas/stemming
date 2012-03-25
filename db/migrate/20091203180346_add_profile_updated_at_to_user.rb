class AddProfileUpdatedAtToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :profile_updated_at, :datetime
  end

  def self.down
    remove_column :users, :profile_updated_at
  end
end
