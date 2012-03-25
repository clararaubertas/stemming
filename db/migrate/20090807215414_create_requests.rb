class CreateRequests < ActiveRecord::Migration
  def self.up
    create_table :requests do |t|
      t.column :user_id, :int
      t.column :recipient_id, :int
      t.column :request_type, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :requests
  end
end
