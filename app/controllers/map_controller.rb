class MapController < ApplicationController
  def index
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true, :map_type => true)
    @map.center_zoom_init([49.12,-56.453],2)
    
    if trip = Trip.find(params[:id])
      @locations = trip.locations
    end
  end
  
  def ajax_add_marker
  	results = Geocoding::get(params[:location])
  	if results.status == Geocoding::GEO_SUCCESS
  		coord = results[0].latlon
  		
  	  #l = Location.create(:name => params[:location], :latitude => coord[0], :longitude => coord[1])
  	  #l.update_attribute(:date, Time.parse(params[:date])) if !params[:date].blank?

      render :update do |page|
        @map = Variable.new("map")
        page << @map.set_center(GLatLng.new(coord), 3)
        page << @map.add_overlay(GMarker.new(coord, :title => params[:location], :info_window => params[:location]))
      end
    end
  end

#  GMarker.new([12.4,65.6],:info_window => "<b>I'm a Popup window</b>",:title => "Tooltip")
#  GMarker.new(GLatLng.new([12.3,45.6]))
#  GMarker.new("Rue Clovis Paris France", :title => "geocoded")
#	 GPolyline.new([[12.4,65.6],[4.5,61.2]],"#ff0000",3,1.0)  

  def ajax_go_to
  	results = Geocoding::get(params[:location])
  	if results.status == Geocoding::GEO_SUCCESS
  		coord = results[0].latlon
      render :update do |page|
        @map = Variable.new("map")
        page << @map.set_center(GLatLng.new(coord), 3)
      end
    end 
  end

  def ajax_trip_locations
    render :partial => 'map/partials/trip'
  end
end
