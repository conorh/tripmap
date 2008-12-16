class MapController < ApplicationController
#  before_filter :require_user, :except => [:new, :index, :ajax_go_to, :ajax_go_to_marker]
  
  include ActionView::Helpers::AssetTagHelper
  
  def new
    @trip = Trip.create
    session[:trip] = @trip.id
        
    if !params[:location].blank? and location = Location.geocode(params[:location])
      @trip.locations << location
    elsif !params[:location].blank?
      flash[:notice] = "Sorry we were unable to locate #{params[:location]}."
    end
    
    create_map
    
    redirect_to :action => 'index', :id => @trip.id
  end
  
  def index
    # Search for a trip from the session, by id, or create a new one 
    unless (params[:id] and @trip = Trip.find_by_id(params[:id])) or @trip = Trip.find_by_id(session[:trip])
      flash[:error] = "Sorry could not find a map."
      redirect_to "/" and return
    end

    @page_title = @trip.name unless @trip.name.blank?    
    
    create_map
  end
  
  def ajax_edit_marker
    ajax_remove_marker and return if params[:commit] =~ /remove/i    
    @trip = Trip.find(session[:trip])
    @location = @trip.locations.find(params[:id])
    
  	results = Geocoding::get(params[:location][:name])
  	if results.status == Geocoding::GEO_SUCCESS
  		coord = results[0].latlon

  		# Create the location object
  	  location = @location.update_attributes(params[:location].merge(:latitude => coord[0], :longitude => coord[1]))

      icon = GIcon.new(:copy_base => GIcon::DEFAULT, :image => image_path("map_markers/marker#{@trip.locations.count}.png"))
      # Plot the location object on the map using a GMarker
      render :update do |page|
        @map = Variable.new("map")
        page << @map.set_center(GLatLng.new(coord), 3)
        page << "trip_markers.removeMarker(#{location.id})" 
        page << "trip_markers.addMarker(#{GMarker.new(coord, :icon => icon).create}, #{location.id})" 
        page.replace_html("locations_div", render(:partial => '/map/partials/trip', :locals => {:locations => @trip.locations}))
      end
    end
  end
    
  # Add a location to the map
  def ajax_add_marker    
    @trip = Trip.find(session[:trip])
    
  	results = Geocoding::get(params[:location][:name])
  	if results.status == Geocoding::GEO_SUCCESS
  		coord = results[0].latlon
  		
  		# Create the location object
  	  l = @trip.locations.create(params[:location].merge(:latitude => coord[0], :longitude => coord[1]))

      icon = GIcon.new(:copy_base => GIcon::DEFAULT, :image => image_path("map_markers/marker#{@trip.locations.count}.png"))
      # Plot the location object on the map using a GMarker
      render :update do |page|
        @map = Variable.new("map")
        page << @map.set_center(GLatLng.new(coord), 3)
        page << "trip_markers.addMarker(#{GMarker.new(coord, :icon => icon).create}, #{l.id})" 
        page.replace_html("locations_div", render(:partial => '/map/partials/trip', :locals => {:locations => @trip.locations}))
      end
    end
  end
  
  # Join up two locations with a polyline
  def ajax_join_locations
    @trip = Trip.find_by_id(session[:trip])
    start_location = @trip.locations.find_by_id(params[:start])
    end_location = @trip.locations.find_by_id(params[:end])
    
    if params[:next_travel_method].blank?
      start_location.update_attributes(:next_location => nil, :next_travel_method => nil)
      render :update do |page|
        @map = Variable.new("map")
        page << "trip_polylines.removePolyline(#{start_location.id})"   
      end
    else      
      start_location.update_attributes(:next_location => end_location, :next_travel_method => params[:next_travel_method])
      travel_method = Location::TRAVEL_TYPES[params[:next_travel_method]]
      render :update do |page|
        @map = Variable.new("map")      
        page << "trip_polylines.removePolyline(#{start_location.id})" # remove any existing polylines originating from this start location
        page << "trip_polylines.addPolyline(#{GPolyline.new([start_location.coords, end_location.coords], travel_method[:color], travel_method[:weight], travel_method[:opacity]).create}, #{start_location.id})"
      end   
    end
  end
  
  def ajax_go_to_marker
    location = Location.find(params[:id])
    render :update do |page|
      if location      
        @map = Variable.new("map")
        page << @map.set_center(GLatLng.new(location.coords), 4)
      end
    end
  end
  
  # Go to a location on the map
  def ajax_go_to
  	results = Geocoding::get(params[:location])
  	
  	if results.status == Geocoding::GEO_SUCCESS
  		coords = results[0].latlon
      render :update do |page|
        @map = Variable.new("map")
        page << @map.set_center(GLatLng.new(coords), 4)
      end
    end 
  end
  
  # List out all the locations for a trip
  def ajax_trip_locations
    @trip = Trip.find_by_id(session[:trip])
    render :partial => 'map/partials/trip', :locations => @trip.locations
  end
  
  # Remove a location from the map
  def ajax_remove_marker
    @trip = Trip.find_by_id(session[:trip])
    location = @trip.locations.find_by_id(params[:id])
    
    render :update do |page|
      @map = Variable.new("map")
      page << "trip_markers.removeMarker(#{location.id})"
        
      # Remove any polylines originating from this location
      page << "trip_polylines.removePolyline(#{location.id})"
      # Find any locations pointing to this location and remove their polylines      
      @trip.locations.find_all_by_next_location_id(location.id).each do |l| 
        page << "trip_polylines.removePolyline(#{l.id})"
        l.update_attributes(:next_location_id => nil, :next_travel_method => nil)
      end
      
      location.destroy
      page.replace_html("locations_div", render(:partial => '/map/partials/trip', :locals => {:locations => @trip.locations}))      
    end
  end

private

  def create_map
    @map = GMap.new("map_div")
    @map.control_init(:large_map => true, :map_type => true)

    # Plot the locations and journey lines for the current trip on the map
    map_data = {:markers => {}, :polylines => {}}
    @trip.locations.each_with_index do |l, index|
      icon = GIcon.new(:copy_base => GIcon::DEFAULT, :image => image_path("map_markers/marker#{index+1}.png"))
      map_data[:markers][l.id] = GMarker.new([l.latitude,l.longitude], :icon => icon)
      if l.next_location
        map_data[:polylines][l.id] = GPolyline.new([l.coords, l.next_location.coords],"#ff0000",3,1.0)
      end
    end

    @map.overlay_global_init(GMarkerGroup.new(true, map_data[:markers]), "trip_markers")  	
    @map.overlay_global_init(GPolylineGroup.new(true, map_data[:polylines]), "trip_polylines")

    if @trip.locations.length > 0
      @map.center_zoom_on_points_init(*@trip.locations.collect {|l| [l.latitude, l.longitude] })
    else
      @map.center_zoom_init([49.12,-56.453],2)
    end
  end
end

#A GOverlay representing a group of GPolylines indexed by id.
class GPolylineGroup
  include MappingObject
  attr_accessor :active, :polylines_by_id

  def initialize(active = true , markers = nil)
    @active = active
    @markers_by_id = markers
  end
  
  def create
    "new GPolylineGroup(#{MappingObject.javascriptify_variable(@active)},#{MappingObject.javascriptify_variable(@markers_by_id)})"
  end
end
