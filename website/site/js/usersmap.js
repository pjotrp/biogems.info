var map, layer, osm, gmap;

function init(){
    OpenLayers.ProxyHost="/proxy/?url=";
//    map = new OpenLayers.Map('map');
map = new OpenLayers.Map({
    div: "map",
    allOverlays: true
});

    layer = new OpenLayers.Layer.WMS( "OpenLayers WMS", 
        "http://vmap0.tiles.osgeo.org/wms/vmap0", {layers: 'basic'} );
    osm = new OpenLayers.Layer.OSM("Open Sreeet Map");
    gmap = new OpenLayers.Layer.Google("Google Streets", {visibility: false});
        
    map.addLayers([osm]);

    map.setCenter(new OpenLayers.LonLat(0, 0), 0);

    var newl = new OpenLayers.Layer.Text( "text", { location:"./js/OpenLayer/textfile.txt"} );
    map.addLayer(newl);

    var markers = new OpenLayers.Layer.Markers( "Markers" );
    map.addLayer(markers);

    var size = new OpenLayers.Size(21,25);
    var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
    var icon = new OpenLayers.Icon('http://www.openlayers.org/dev/img/marker.png',size,offset);
//    markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(5.73788,50.92818),icon));
//    markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(9.413805, 45.794057),icon));

/*
    var halfIcon = icon.clone();
    markers.addMarker(new OpenLayers.Marker(new OpenLayers.LonLat(0,45),halfIcon));

    marker = new OpenLayers.Marker(new OpenLayers.LonLat(90,10),icon.clone());
    marker.setOpacity(0.2);
    marker.events.register('mousedown', marker, function(evt) { alert(this.icon.url); OpenLayers.Event.stop(evt); });
    markers.addMarker(marker); 
*/
    map.addControl(new OpenLayers.Control.LayerSwitcher());
    map.zoomToMaxExtent();

//    halfIcon.setOpacity(0.5);
}