class AddNewUserFields < ActiveRecord::Migration
  def self.up
    add_column :users, :age_range, :string
    add_column :users, :career, :text
  end

  def self.down
    remove_column :users, :age_range
    remove_column :users, :career
  end
end
