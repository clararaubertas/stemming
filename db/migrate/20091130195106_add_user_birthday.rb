class AddUserBirthday < ActiveRecord::Migration
  def self.up
    remove_column :users, :age_range
    add_column :users, :birthday, :datetime
  end

  def self.down
    remove_column :users, :birthday
    add_column :users, :age_range, :string
  end
end
