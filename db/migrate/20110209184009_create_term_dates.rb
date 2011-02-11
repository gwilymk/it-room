class CreateTermDates < ActiveRecord::Migration
  def self.up
    create_table :term_dates do |t|
      t.date :term_begin
      t.date :term_end
      t.integer :week_start

      t.timestamps
    end
  end

  def self.down
    drop_table :term_dates
  end
end
