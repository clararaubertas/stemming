class AddTrackbacksSent < ActiveRecord::Migration
  def self.up
    add_column :posts, :trackbacks_sent, :boolean, :default => false
  end

  def self.down
    remove_column :posts, :trackbacks_sent
  end

end
