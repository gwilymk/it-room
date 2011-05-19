class AddCommentsToBookingDatabase < ActiveRecord::Migration
  def self.up
    change_table :bookings do |t|
      t.string :reason
      t.integer :ict_area
      t.integer :ict_level
    end
  end

  def self.down
    remove_column :bookings, :reason
    remove_column :bookings, :ict_area
    remove_column :bookings, :ict_level
  end
end

