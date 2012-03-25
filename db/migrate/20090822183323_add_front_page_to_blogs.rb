class AddFrontPageToBlogs < ActiveRecord::Migration
  def self.up
    add_column :posts, :front_page, :boolean
  end

  def self.down
    remove_column :posts, :front_page
  end
end
