class Location < ActiveRecord::Base
  belongs_to :trip
  has_one :next_location, :class_name => 'Location', :foreign_key => 'next_location_id'
  
  TRAVEL_TYPES = {
    'car' => {:color => "#0000ff", :weight => 3, :opacity => 1.0},
    'bus' => {:color => "#0000ff", :weight => 3, :opacity => 1.0},
    'air' => {:color => "#ff0000", :weight => 3, :opacity => 1.0},
    'boat' => {:color => "#0000ff", :weight => 3, :opacity => 1.0},
    'foot' => {:color => "#ff00ff", :weight => 3, :opacity => 1.0},
    'train' => {:color => "#ff00ff", :weight => 3, :opacity => 1.0},
  }
  
  def coords
    [self.latitude, self.longitude]
  end
  
  
  def self.geocode(location)
  	results = Geocoding::get(location)
  	if results.status == Geocoding::GEO_SUCCESS
  	  coord = results[0].latlon
      Location.new(:name => location, :latitude => coord[0], :longitude => coord[1])
    end
  end
end