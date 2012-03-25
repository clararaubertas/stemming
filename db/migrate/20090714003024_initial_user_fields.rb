class InitialUserFields < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :bio, :text
    add_column :users, :education, :text
    add_column :users, :networking, :boolean
    add_column :users, :mentoring, :boolean
    add_column :users, :menteeing, :boolean

    create_table "interests_users", :id => false do |t|
      t.column "interest_id", :integer
      t.column "user_id", :integer
    end
    add_index "interests_users", "interest_id"
    add_index "interests_users", "user_id"
  end
  
  def self.down
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :city
    remove_column :users, :state
    remove_column :users, :bio
    remove_column :users, :education
    remove_column :users, :networking
    remove_column :users, :mentoring
    remove_column :users, :menteeing
  end

end
