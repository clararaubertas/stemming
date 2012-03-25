class DropInterests < ActiveRecord::Migration
  def self.up
    drop_table :interests
  end

  def self.down
    create_table :interests do |t|
      t.column :name, :string
      t.timestamps
    end
  end
end
