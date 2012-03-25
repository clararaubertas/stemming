class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.column :user_id, :int
      t.column :activity_type, :string
      t.column :activity_id, :int
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
