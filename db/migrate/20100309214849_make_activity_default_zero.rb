class MakeActivityDefaultZero < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change_default :activity_level, 0
    end
  end

  def self.down
  end
end
