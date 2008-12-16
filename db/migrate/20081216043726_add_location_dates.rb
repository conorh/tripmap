class AddLocationDates < ActiveRecord::Migration
  def self.up
    rename_column(:locations, :date, :start_date)
    add_column(:locations, :end_date, :datetime)
    add_column(:locations, :notes, :text)
  end

  def self.down
    rename_column(:locations, :start_date, :date)
    drop_column(:locations, :end_date)
    drop_column(:locations, :notes)
  end
end
