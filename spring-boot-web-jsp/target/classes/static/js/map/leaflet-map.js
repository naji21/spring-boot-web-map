/**
 * 
 */

L.Control.Print = L.Control.extend({
  options: {
    position: 'topright',
    //  weather to use keyboard control for this plugin
    
    type: ''// measure type Polyline, Polygon
  },
  initialize: function (options) {
    //  apply options to instance
    L.Util.setOptions(this, options)
  },

  onAdd: function (map) {
    var className = 'leaflet-control-zoom leaflet-bar leaflet-control'
    var container = L.DomUtil.create('div', className)
    this._createButton('&#9113;', '저장',
    'leaflet-control-measure leaflet-bar-part leaflet-bar-part-top-and-bottom',
    container, this._save, this)
    
    if (this.options.keyboard) {
      L.DomEvent.on(document, 'keydown', this._onKeyDown, this)
    }

    return container
  },
  _createButton: function (html, title, className, container, fn, context) {
    var link = L.DomUtil.create('a', className, container)
    link.innerHTML = html
    link.href = '#'
    link.title = title

    L.DomEvent
      .on(link, 'click', L.DomEvent.stopPropagation)
      .on(link, 'click', L.DomEvent.preventDefault)
      .on(link, 'click', fn, context)
    return link
  },
  
  _save: function (){
	leafletImage(this._map, function(err, mapCanvas) {
      // now you have canvas
      // example thing to do with that canvas:
     	/*
      var img = document.createElement('img');
      var dimensions = letMap.getSize();
      img.width = dimensions.x;
      img.height = dimensions.y;
      img.src = canvas.toDataURL();
      document.getElementById('images').innerHTML = '';
      document.getElementById('images').appendChild(img);
      */
		var a = document.createElement('a');
	    a.href = mapCanvas.toDataURL();
	    a.download = "map.png";
	    document.body.appendChild(a);
	    a.click();
	});
  }
})

L.control.print = function (options) {
  return new L.Control.Print(options)
}

L.Map.mergeOptions({
  printControl: false
})

L.Map.addInitHook(function () {
  if (this.options.printControl) {
    this.printControl = new L.Control.Print()
    this.addControl(this.printControl)
  }
})

var letMap;

var readConfigAddleafletLayer = function(map){
	var overlayLayers = {
		overlayLayer : null
	};
	
	var layers = [];
	
	$.each(val, function(idx, config){
		
		// create map zoom-levels for WMTS
	    var resolutions = new Array(26);
		var matrixIds = new Array(26);
	    for (var i = 0; i < config.ZoomLevels; ++i) {
			matrixIds[i] = {
				identifier    : '' + (i-1),
	            topLeftCorner : new L.LatLng(20037508.3428,-20037508.3428)							
			};
			
	    }
		
	    var layer = new L.tileLayer.wmts(
			config.URL, 
	    	{
				layer: config.InternalLayerName,
				style: "",
		        tilematrixSet: config.MatrixSet,
		        format: "image/png",
	            matrixIds: matrixIds,
	            tileSize: config.TileSize
	    	} 
	    );
	    
	    layers.push(layer);
	});
	
	overlayLayers.overlayLayer = L.layerGroup(layers);
	
	return overlayLayers;
}
    
$(document).ready(function(){

	//leaflet 지도 띄우기
	letMap = L.map('letMap', { zoomControl: false, preferCanvas: true, crs: L.CRS.EPSG900913, minZoom: 0 });
	
	letMap.once('load', function(e){
		alert('Leaflet Load!');
	});
	
	letMap.setView(L.CRS.EPSG900913.unproject({ x: 14128579.82, y: 4512570.74 }), 14);
	
	//Vworld Tile 변경
	var vworldBaseLayer = L.tileLayer('http://xdworld.vworld.kr:8080/2d/Base/201802/{z}/{x}/{y}.png');
	
	var vworldSatelliteLayer = L.layerGroup([L.tileLayer('http://xdworld.vworld.kr:8080/2d/Satellite/201802/{z}/{x}/{y}.jpeg'), L.tileLayer('http://xdworld.vworld.kr:8080/2d/Hybrid/201802/{z}/{x}/{y}.png')]);
	
	var layers = {
		vworldBase: vworldBaseLayer.addTo(letMap),
		vworldSatellite: vworldSatelliteLayer,
	};
	
	var overlayLayers = readConfigAddleafletLayer(letMap);
	
	L.control.layers(layers, overlayLayers, { position: 'topleft', collapsed: false }).addTo(letMap);
	
	
	var zoomsliderControl = new L.control.zoomslider({ position: 'topright' });
	zoomsliderControl.addTo(letMap);
	
	var printControl = new L.control.print({ position: 'topleft' });
	printControl.addTo(letMap);
	
	var measureControl = new L.control.measure({
		//  control position
		position: 'topleft',
		//  weather to use keyboard control for this plugin
		keyboard: true,
		//  shortcut to activate measure
		activeKeyCode: 'M'.charCodeAt(0),
		//거리재기 초기화 코드(esc버튼 코드 :27)  //shortcut to cancel measure, defaults to 'Esc'
		cancelKeyCode: 27,
		//  line color
		lineColor: 'red',
		//  line weight
		lineWeight: 5,
		//  line dash
		lineDashArray: '6, 6',
		//  line opacity
		lineOpacity: 1,
		//  distance formatter
		// formatDistance: function (val) {
		//   return Math.round(1000 * val / 1609.344) / 1000 + 'mile';
		// }
	});
	measureControl.addTo(letMap);
	
	L.control.mousePosition().addTo(letMap);
	
	letMap.on("click", function(e) {
	    /*
	    -----------------------------------------------------------------------------
	    EPSG4326					L.geoJSON/ L.geoJson			L.Proj.geoJson
	    -----------------------------------------------------------------------------
	    1. bounds.toBBoxString()	Works						Works
	    2. sw.x,sw.y,ne.x,ne.y		Works						Works
	    -----------------------------------------------------------------------------
	    EPSG3857					L.geoJSON/ L.geoJson			L.Proj.geoJson
	    -----------------------------------------------------------------------------
	    1. bounds.toBBoxString()	No features error			No features error
	    2. sw.x,sw.y,ne.x,ne.y		No geometry highlight		Works
	    -----------------------------------------------------------------------------
	    */
	    var _layers = this._layers,
	      layers = [],
	      versions = [],
	      styles = [];
		/*
	    for (var x in _layers) {
	      var _layer = _layers[x];
	      if (_layer.wmsParams) {
	        layers.push(_layer.wmsParams.layers);
	        versions.push(_layer.wmsParams.version);
	        styles.push(_layer.wmsParams.styles);
	      }
	    }
		*/
	
	    var loc = e.latlng,
	      xy = e.containerPoint, // xy = this.latLngToContainerPoint(loc,this.getZoom())
	      size = this.getSize(),
	      bounds = this.getBounds(),
	      crs = this.options.crs,
	      sw = crs.project(bounds.getSouthWest()),
	      ne = crs.project(bounds.getNorthEast()),
	      //url = "http://localhost:9090/maps",
	      url = "http://59.6.157.153:9090/maps",
	      obj = {
	        service: "WMS", // WMS (default)
	        version: '1.3.0',
	        request: "GetFeatureInfo",
	        layers: 'scl_facility',
	        styles: '',
	        crs: 'EPSG:900913',
	        format: 'image/png',
	        // bbox: bounds.toBBoxString(), // works only with EPSG4326, but not with EPSG3857
	        bbox: sw.x + "," + sw.y + "," + ne.x + "," + ne.y, // works with both EPSG4326, EPSG3857
	        width: size.x,
	        height: size.y,
	        query_layers: 'scl_facility',
	        info_format: "application/json", // text/plain (default), application/json for JSON (CORS enabled servers), text/javascript for JSONP (JSONP enabled servers)
	        feature_count: 50 // 1 (default)
	        //exceptions: 'application/json', // application/vnd.ogc.se_xml (default)
	        // format_options: 'callback: parseResponse' // callback: parseResponse (default), use only with JSONP enabled servers, when you want to change the callback name
	      };
		
	    if (parseFloat(obj.version) >= 1.3) {
	    	obj.crs = crs.code;
			obj.i = xy.x;
			obj.j = xy.y;
	    } else {
			obj.srs = crs.code;
			obj.x = xy.x;
			obj.y = xy.y;
	    }
	    $.ajax({
			url: url + L.Util.getParamString(obj, url, true),
			dataType: 'json',
			// dataType: 'jsonp', // use only with JSONP enabled servers
			// jsonpCallback: 'parseResponse', // parseResponse (default), use only with JSONP enabled servers, change only when you changed the callback name in request using format_options: 'callback: parseResponse'
			success: function(data, status, xhr) {
				L.geoJson(data, { coordsToLatLng: function (newcoords) {
				    return (L.CRS.EPSG900913.unproject({ x: newcoords[0], y: newcoords[1]}));
				}, style: function(feature){ return { color: 'rgba(0,0,255,0.5)', weight: 10 } } }).addTo(letMap);
//				leafletImage(letMap, function(err, mapCanvas) {
//		            // now you have canvas
//		            // example thing to do with that canvas:
//		           	/*
//		            var img = document.createElement('img');
//		            var dimensions = letMap.getSize();
//		            img.width = dimensions.x;
//		            img.height = dimensions.y;
//		            img.src = canvas.toDataURL();
//		            document.getElementById('images').innerHTML = '';
//		            document.getElementById('images').appendChild(img);
//		            */
//		        	var link = document.getElementById('image-download');
//				          link.href = mapCanvas.toDataURL();
//				          link.click();
//	            });
			},
			error: function(xhr, status, err) {
				debugger;
			}
	    });
	});
});