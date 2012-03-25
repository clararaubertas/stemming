class AddSentAtToRequest < ActiveRecord::Migration
  def self.up
    add_column :requests, :sent_at, :datetime
  end

  def self.down
    remove_column :requests, :sent_at, :datetime
  end
end
