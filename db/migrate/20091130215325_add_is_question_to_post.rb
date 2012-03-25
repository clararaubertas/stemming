class AddIsQuestionToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :is_question, :boolean, :default => false
  end

  def self.down
    remove_column :posts, :is_question
  end
end
