class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.integer :trip_id
      t.string :name
      t.text :description
      t.float :latitude
      t.float :longitude
      t.datetime :date
      t.integer :next_location_id
      t.string :next_travel_method
      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
