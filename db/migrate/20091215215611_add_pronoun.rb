class AddPronoun < ActiveRecord::Migration
  def self.up
    add_column :users, :pronoun_type, :string, :default => 'they'
  end

  def self.down
    remove_column :users, :pronoun_type
  end
end
