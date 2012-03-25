class AddTagType < ActiveRecord::Migration
  def self.up
    add_column :tags, :object_type, :string
  end

  def self.down
    remove_column :tags, :object_type
  end
end
