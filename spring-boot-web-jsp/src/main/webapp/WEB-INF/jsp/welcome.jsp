<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>

<link rel="stylesheet" type="text/css"
	href="webjars/bootstrap/3.3.7/css/bootstrap.min.css" />
<link rel="stylesheet" type="text/css" href="js/ol.css" />
<link rel="stylesheet" type="text/css" href="js/ol-ext.css" />

<link type="text/css" rel="stylesheet" href="js/leaflet.css" />
<link type="text/css" rel="stylesheet" href="js/leaflet-mouseposition.css" />
<!-- 
	<spring:url value="/css/main.css" var="springCss" />
	<link href="${springCss}" rel="stylesheet" />
	 -->
<c:url value="/css/main.css" var="jstlCss" />
<link href="${jstlCss}" rel="stylesheet" />
<style>
.olMap {
	height: 470px;
    width: 100%;
}

.leafletMap {
	height: 470px;
    width: 100%;
}
</style>
</head>
<body>

	<nav class="navbar navbar-inverse">
		<div class="container">
			<div class="navbar-header">
				<a class="navbar-brand" href="#">Spring Boot</a>
			</div>
			<div id="navbar" class="collapse navbar-collapse">
				<ul class="nav navbar-nav">
					<li class="active"><a href="#">Home</a></li>
					<li><a href="#about">About</a></li>
				</ul>
			</div>
		</div>
	</nav>

	<div class="container-fluid">
		<!-- 
		<div class="starter-template">
			<h1>Spring Boot Web JSP Example</h1>
			<h2>Message: ${message}</h2>
		</div>
		 -->
		
		<div class="row">
	    	<div class="col-sm-6" style="border-right: 1px solid;">
				<div class="olMap" id="olMap"></div>
			</div>
			<div class="col-sm-6" style="border-right: 1px solid;">
				<div class="leafletMap" id="letMap"></div>
			</div>
	  	</div>

	</div>
	<!-- /.container -->
	<script type="text/javascript"
		src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript"
		src="webjars/bootstrap/3.3.7/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/ol.js"></script>
	<script type="text/javascript" src="js/ol-ext.js"></script>
	
	<script type="text/javascript" src="js/leaflet.js"></script>
	<script type="text/javascript" src="js/leaflet-wmts.js"></script>
	<script type="text/javascript" src="js/leaflet-mouseposition.js"></script>
	<script src='https://unpkg.com/leaflet-image@latest/leaflet-image.js'></script>
	<script type="text/javascript">
		var olMap, letMap;
		var val = [{
	        "ExternalLayerName": "시설물도",
	        "InternalLayerName": "Facility",
	        "MatrixSet": "EPSG-900913",
	        "ZoomLevels": 21,
	        "ZoomOffset": -1,
	        "TileSize": 512,
	        "Opacity": 0.7,
	        "IsBaseLayer": false,
	        "LayerGroup": "aaaa",
	        "Visible": true,
	        "URL": "http://59.6.157.173:9090/maps"
	    },{
	        "ExternalLayerName": "지형도",
	        "InternalLayerName": "Basemap",
	        "MatrixSet": "EPSG-900913",
	        "ZoomLevels": 21,
	        "ZoomOffset": -1,
	        "TileSize": 512,
	        "Opacity": 0.7,
	        "IsBaseLayer": false,
	        "LayerGroup": "aaaa",
	        "Visible": true,
	        "URL": "http://59.6.157.173:9090/maps"
	    }];
		
		var projection = ol.proj.get("EPSG:900913");
		var projectionExtent = projection.getExtent();
		
		var wmtsZoomLevels = function wmtsZoomLevels(numZoomLevels) {

	      // create map zoom-levels for WMTS
	      var resolutions = new Array(26);
			var matrixIds = new Array(26);
	      for (var i = 0; i < numZoomLevels; ++i) {
	    	resolutions[i] = size / Math.pow(2, i);
	        matrixIds[i] = '' + i;
	      }
	      //return matrixIds;
	      return {
	    	  resolutions: resolutions,
	    	  matrixIds: matrixIds
	      };
	    };
	    
	    var readConfigAddOlLayer = function(map){
	    	$.each(val, function(idx, config){
	    		var size = ol.extent.getWidth(projectionExtent) / config.TileSize;
	    		
	    		// create map zoom-levels for WMTS
			    var resolutions = new Array(26);
				var matrixIds = new Array(26);
			    for (var i = 0; i < config.ZoomLevels; ++i) {
					resolutions[i] = size / Math.pow(2, i);
					matrixIds[i] = '' + i;
			    }
	    		
	    		map.addLayer(new ol.layer.Tile({
					source: new ol.source.WMTS({
			            name: config.ExternalLayerName,
			            url: config.URL,
			            //url: 'http://59.6.157.153:9090/maps?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=Basemap&STYLE=&TILEMATRIXSET={TileMatrixSet}&TILEMATRIX={TileMatrix}&TILEROW={TileRow}&TILECOL={TileCol}&FORMAT=image%2Fpng',
			            layer: config.InternalLayerName,
			           	projection: projection,
				        matrixSet: config.MatrixSet,
			            tileGrid: new ol.tilegrid.WMTS({
			            	origin: ol.extent.getTopLeft(projectionExtent),
			            	tileSize: [config.TileSize, config.TileSize],
			            	resolutions: resolutions,
				            matrixIds: matrixIds
			            }),
			            zoomOffset: config.ZoomOffset,
			            format: 'image/png',
			            //service: 'WMTS',
			            //requestEncoding: "REST",
			            style: '',
			            isBaseLayer: config.IsBaseLayer,
			            visibility: config.Visible,
			            selectable: ('Selectable' in val) ? config.Selectable : true,
			            //layerGroup: val.LayerGroup,
			            //transitionEffect: null,
			            //wrapDateLine: true,
			            wrapX: true,
			            isStyledLayer: config.IsStyledLayer ? true : false,
			           	crossOrigin: "Anonymous"
					})
		        }));
	    	});
	    }
	    
	    var readConfigAddleafletLayer = function(map){
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
	    		
	    		map.addLayer(new L.tileLayer.wmts(
	    			config.URL, 
    		    	{
    		    		layer: config.InternalLayerName,
    		    		style: "",
                        tilematrixSet: config.MatrixSet,
                        format: "image/png",
                        matrixIds: matrixIds,
                        tileSize: config.TileSize
    		    	} 
    		    ));
	    	});
	    }
		    
		$(document).ready(function(){
			olMap = new ol.Map({
				target: 'olMap',
			    layers: [
			      	new ol.layer.Tile({
			        	source: new ol.source.XYZ({
			        		url: 'http://xdworld.vworld.kr:8080/2d/Base/201802/{z}/{x}/{y}.png'
			                , crossOrigin: "Anonymous"
			        	})
			      	})
				],
				view: new ol.View({
			    	center: [14128579.82, 4512570.74],
			        zoom: 14,
			        minZoom: 0,
			        maxZoom: 19
				}),
			});
			
			readConfigAddOlLayer(olMap);
			
			olMap.addControl(new ol.control.MousePosition());
			
			olMap.on('singleclick', function(evt){
				var size = ol.extent.getWidth(projectionExtent) / 512;
				var resolutions = new Array(26);
				var matrixIds = new Array(26);
			    for (var i = 0; i < 21; ++i) {
			    	resolutions[i] = size / Math.pow(2, i);
					matrixIds[i] = '' + i;
			    }
			    
				var wmsSource = new ol.source.TileWMS({
		            url: 'http://localhost:9090/maps',
		            //url: 'http://59.6.157.153:9090/maps',
		           	params: { 'LAYERS': 'scl_facility', 'TRANSPARENT': undefined },
					crossOrigin: "Anonymous"
				});
				
				var url = wmsSource.getFeatureInfoUrl(
					    evt.coordinate, olMap.getView().getResolution(), 'EPSG:900913',
					    {'INFO_FORMAT': 'application/json', 'FEATURE_COUNT': 50});
				
				if (url) {
			        var parser = new ol.format.GeoJSON();
			        $.ajax({
			          url: url,
			          async: false,
			          dataType: 'json',
			          //jsonpCallback: 'parseResponse',
			          success: function(response) {
			        	  var result = parser.readFeatures(response);
				          if (result.length) {
				          	debugger;
				          	
				          	var vectorSource = new ol.source.Vector({
				          	  features: result
				          	});
				          	
				          	
				          	var vectorLayer = new ol.layer.Vector({
				          	  source: vectorSource,
				          	  style: new ol.style.Style({
				          	    stroke: new ol.style.Stroke({
				          	      color: 'rgba(0,0,255,0.5)',
				          	      width: 10
				          	    })
				          	  })
				          	});
				          	
				          	olMap.addLayer(vectorLayer);
				          } 
			          },
			          error: function(err) { debugger; }
			        });
			        
			        olMap.once('rendercomplete', function() {
			            var mapCanvas = document.createElement('canvas');
			            var size = olMap.getSize();
			            mapCanvas.width = size[0];
			            mapCanvas.height = size[1];
			            var mapContext = mapCanvas.getContext('2d');
			            Array.prototype.forEach.call(document.querySelectorAll('.ol-layer canvas'), function(canvas) {
			              if (canvas.width > 0) {
			                var opacity = canvas.parentNode.style.opacity;
			                mapContext.globalAlpha = opacity === '' ? 1 : Number(opacity);
			                var transform = canvas.style.transform;
			                // Get the transform parameters from the style's transform matrix
			                var matrix = transform.match(/^matrix\(([^\(]*)\)$/)[1].split(',').map(Number);
			                // Apply the transform to the export map context
			                CanvasRenderingContext2D.prototype.setTransform.apply(mapContext, matrix);
			                mapContext.drawImage(canvas, 0, 0);
			              }
			            });
			            if (navigator.msSaveBlob) {
			              // link download attribuute does not work on MS browsers
			              navigator.msSaveBlob(mapCanvas.msToBlob(), 'map.png');
			            } else {
			              var link = document.getElementById('image-download');
			              link.href = mapCanvas.toDataURL();
			              link.click();
			            }
			          });
			          olMap.renderSync();
				}
				
			});
			
			//leaflet 지도 띄우기
			letMap = L.map('letMap', { preferCanvas: true, crs: L.CRS.EPSG900913, minZoom: 0, center: L.CRS.EPSG900913.unproject({ x: 14128579.82, y: 4512570.74 }), zoom: 14 });
			
		    //Vworld Tile 변경
		    L.tileLayer('http://xdworld.vworld.kr:8080/2d/Base/201802/{z}/{x}/{y}.png').addTo(letMap);
		    
		    readConfigAddleafletLayer(letMap);
		    
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
		          url = "http://localhost:9090/maps",
		          //url = "http://59.6.157.153:9090/maps",
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
		            debugger;
		            
		            leafletImage(letMap, function(err, mapCanvas) {
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
		            	var link = document.getElementById('image-download');
				          link.href = mapCanvas.toDataURL();
				          link.click();
		            });
		          },
		          error: function(xhr, status, err) {
		        	debugger;
		          }
		        });
		   });
		});
		
	</script>
	<div id='images'></div>
	<a id="image-download" download="map.png"></a>
</body>

</html>
