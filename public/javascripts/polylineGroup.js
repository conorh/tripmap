function GPolylineGroup(active, polylinesById) {
    this.active = active;
    this.polylinesById = polylinesById || new Object();
}

GPolylineGroup.prototype = new GOverlay();

GPolylineGroup.prototype.initialize = function(map) {
    this.map = map;
    
    if(this.active){
		for(var id in this.polylinesById){
		    this.map.addOverlay(this.polylinesById[id]);
		}
    }
}

//If not already done (ie if not inactive) remove all the polylines from the map
GPolylineGroup.prototype.remove = function() {
    this.deactivate();
}

GPolylineGroup.prototype.redraw = function(force){
    //Nothing to do : polylines are already taken care of
}

//Copy the data to a new Polyline Group
GPolylineGroup.prototype.copy = function() {
    var overlay = new GPolylineGroup(this.active);
    overlay.polylinesById = this.polylinesById; //Need to do deep copy
    return overlay;
}

//Inactivate the Polyline group and clear the internal content
GPolylineGroup.prototype.clear = function(){
    //deactivate the map first (which removes the polylines from the map)
    this.deactivate();
    //Clear the internal content
    this.polylinesById = new Object();
}

//Add a polyline to the GPolylineGroup ; Adds it now to the map if the GPolylineGroup is active
GPolylineGroup.prototype.addPolyline = function(polyline,id){
	this.polylinesById[id] = polyline;
    if(this.active && this.map != undefined ){
	   this.map.addOverlay(polyline);
    }
}

//Add a polyline to the GPolylineGroup ; Adds it now to the map if the GPolylineGroup is active
GPolylineGroup.prototype.removePolyline = function(id){
	var polyline = this.polylinesById[id];
    if(polyline != undefined && this.active && this.map != undefined ){
	   this.polylinesById[id] = null;
	   this.map.removeOverlay(polyline);
    }
}

//Open the info window (or info window tabs) of a polyline
GPolylineGroup.prototype.showPolyline = function(id){
    var polyline = this.polylinesById[id];
    if(polyline != undefined) {
	   GEvent.trigger(polyline,"click");
    }
}

//Activate (or deactivate depending on the argument) the GPolylineGroup
GPolylineGroup.prototype.activate = function(active){
    active = (active == undefined) ? true : active;
    if(!active){
	if(this.active) {
	    if(this.map != undefined) {
		   for(var id in this.polylinesById) {
		      this.map.removeOverlay(this.polylinesById[id]);
		   }
	    }
	    this.active = false;
	}
    } else {
		if(!this.active) {
		    if(this.map != undefined) {
				for(var id in this.polylinesById) {
				    this.map.addOverlay(this.polylinesById[id]);
				}
		    }
		    this.active = true;
		}
    }
}

GPolylineGroup.prototype.centerAndZoomOnpolylines = function() {
    if(this.map != undefined){
		var tmppolylines = [];
		for (var id in this.polylinesById){
		    tmppolylines.push(this.polylinesById[id]);
		}
		if(tmppolylines.length > 0) {
	       this.map.centerAndZoomOnpolylines(tmppolylines);
		} 
    }
}	

//Deactivate the Group Overlay (convenience method)
GPolylineGroup.prototype.deactivate = function(){
    this.activate(false);
}
