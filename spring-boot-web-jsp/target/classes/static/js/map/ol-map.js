ol.control.PrintControl = function (opt_options){
	var options = opt_options || {};
	
	var element = document.createElement('div');
    element.className = 'export-data ol-unselectable ol-control';
    
    var button = document.createElement('button');
    button.innerHTML = '<i class="fa fa-file-image-o" aria-hidden="true"></i>';
    
    element.appendChild(button);
    
    var this_ = this;
    var saveImage = function(e) {
    	debugger;
      e.preventDefault();
      
      var mapCanvas = document.createElement('canvas');
      var size = this_.getMap().getSize();
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
        var link = document.createElement('a');
        link.href = mapCanvas.toDataURL();
        link.download="map.png";
        link.click();
      }
    };
    
    button.addEventListener('click', saveImage, false);
    button.addEventListener('touchstart', saveImage, false);
    
    ol.control.Control.call(this, {
        element: element,
        target: options.target
      });
}

ol.inherits(ol.control.PrintControl, ol.control.Control);

ol.control.MeasureControl = function (opt_options){
	var options = opt_options || {};
	
	var element = document.createElement('div');
    element.className = 'measure-line ol-unselectable ol-control';
    
    var lineButton = document.createElement('button');
    lineButton.title = "거리재기";
    lineButton.innerHTML = '<i>&#8674;</i>';
    
    var squareButton = document.createElement('button');
    squareButton.title = "면적재기";
    squareButton.innerHTML = '<i>&#11091;</i>';
    
    var clearButton = document.createElement('button');
    clearButton.title = "초기화";
    clearButton.innerHTML = '<i>&#128465;</i>';
    
    element.appendChild(lineButton);
    element.appendChild(squareButton);
    element.appendChild(clearButton);
    
    var this_ = this;
    window.measure = null;
    var startMeasuring = function (e, geometryType){
    	this_.getMap().removeInteraction(measuringTool);

	  // var geometryType = "LineString";
	  // var geometryType = "Polygon";
	  var html = geometryType === 'Polygon' ? '<sup>2</sup>' : '';
	  
	  var measuringTool = new ol.interaction.Draw({
	    type: geometryType,
	    source: this_.getMap().layers["measureLayer"].getSource()
	  });
	  
	  measuringTool.on('drawstart', function(event) {
		  
	  
	  
		var tooltipCoord = event.coordinate;
		event.feature.on('change', function(event) {
//		  var measurement = geometryType === 'Polygon' ? event.target.getGeometry().getArea() : event.target.getGeometry().getLength();
//		
//		  var measurementFormatted = measurement > 100 ? (measurement / 1000).toFixed(2) + 'km' : measurement.toFixed(2) + 'm';
			
			
		var measurementFormatted;
		  if (geometryType === 'Polygon') {
			  measurementFormatted = formatArea(event.target.getGeometry());
	          tooltipCoord = event.target.getGeometry().getInteriorPoint().getCoordinates();
	        } else if (geometryType === 'LineString') {
	        	measurementFormatted = formatLength(event.target.getGeometry());
	          tooltipCoord = event.target.getGeometry().getLastCoordinate();
	        }
	  		this_.getMap().getOverlays().getArray()[0].element.innerHTML = measurementFormatted;
	  		this_.getMap().getOverlays().getArray()[0].setPosition(tooltipCoord);
	    });
		
		
	  });
		
	  this_.getMap().addInteraction(measuringTool);
	  
	  if (measureTooltipElement) {
	    measureTooltipElement.parentNode.removeChild(measureTooltipElement);
	  }
	  var measureTooltipElement = document.createElement('div');
		  measureTooltipElement.className = 'ol-tooltip ol-tooltip-measure';
	    var measureTooltip = new ol.Overlay({
		    element: measureTooltipElement,
		    offset: [0, -15],
		    positioning: 'bottom-center'
		  });
		  
		  this_.getMap().addOverlay(measureTooltip);
    };
    
    var endMeasuring = function (e){
    	this_.getMap().removeInteraction(measuringTool);
    	this_.getMap().getOverlays().clear()
    };
    
    /**
     * Format length output.
     * @param {LineString} line The line.
     * @return {string} The formatted length.
     */
    var formatLength = function(line) {
      var length = ol.sphere.getLength(line);
      var output;
      if (length > 100) {
        output = (Math.round(length / 1000 * 100) / 100) +
            ' ' + 'km';
      } else {
        output = (Math.round(length * 100) / 100) +
            ' ' + 'm';
      }
      return output;
    };


    /**
     * Format area output.
     * @param {Polygon} polygon The polygon.
     * @return {string} Formatted area.
     */
    var formatArea = function(polygon) {
      var area = ol.sphere.getArea(polygon);
      var output;
      if (area > 10000) {
        output = (Math.round(area / 1000000 * 100) / 100) +
            ' ' + 'km<sup>2</sup>';
      } else {
        output = (Math.round(area * 100) / 100) +
            ' ' + 'm<sup>2</sup>';
      }
      return output;
    };
    
    lineButton.addEventListener('click', function(e){ startMeasuring(e, "LineString") }, false);
    lineButton.addEventListener('touchstart', function(e){ startMeasuring(e, "LineString") }, false);
    
    squareButton.addEventListener('click', function(e){ startMeasuring(e, "Polygon") }, false);
    squareButton.addEventListener('touchstart', function(e){ startMeasuring(e, "Polygon") }, false);
    
    clearButton.addEventListener('click', function(e){ this_.getMap().layers["measureLayer"].getSource().clear(); }, false);
    clearButton.addEventListener('touchstart', function(e){ this_.getMap().layers["measureLayer"].getSource().clear(); }, false);
    
    ol.control.Control.call(this, {
        element: element,
        target: options.target
      });
}

ol.inherits(ol.control.MeasureControl, ol.control.Control);
	

var olMap;

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
	
	var olMeasureLayer = new ol.layer.Vector({
	  id: "measureLayer",
	  name: "measureLayer",
	  source: new ol.source.Vector()
	});
	
	olMap.layers = {};
	olMap.layers["measureLayer"] = olMeasureLayer;
	
	olMap.addLayer(olMeasureLayer);

	readConfigAddOlLayer(olMap);
	
	olMap.addControl(new ol.control.ZoomSlider());
	
	olMap.addControl(new ol.control.MousePosition());
	
	olMap.addControl(new ol.control.PrintControl());
	
	olMap.addControl(new ol.control.MeasureControl());
	
//	olMap.addControl(new ol.control.LayerSwitcher({ position: "topleft" }));
	
//	var sidebar = new ol.control.Sidebar({ element: 'sidebar', position: 'left' });

//    olMap.addControl(sidebar);
	
	olMap.once('postrender', function(){
		alert('Loaded once!');
	});
	
	olMap.on('singleclick', function(evt){
		var size = ol.extent.getWidth(projectionExtent) / 512;
		var resolutions = new Array(26);
		var matrixIds = new Array(26);
	    for (var i = 0; i < 21; ++i) {
	    	resolutions[i] = size / Math.pow(2, i);
			matrixIds[i] = '' + i;
	    }
	    
		var wmsSource = new ol.source.TileWMS({
	        //url: 'http://localhost:9090/maps',
	        url: 'http://59.6.157.153:9090/maps',
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
	        /*
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
	          */
		}
		
	});
	
	var enableMeasuringTool = function() {
	  olMap.removeInteraction(measuringTool);
	
	  var geometryType = "LineString";
	  // var geometryType = "Polygon";
	  var html = geometryType === 'Polygon' ? '<sup>2</sup>' : '';
	
	  var measuringTool = new ol.interaction.Draw({
	    type: geometryType,
	    source: olMeasureLayer.getSource()
	  });
	
	  measuringTool.on('drawstart', function(event) {
		  olMeasureLayer.getSource().clear();
		
		event.feature.on('change', function(event) {
		  var measurement = geometryType === 'Polygon' ? event.target.getGeometry().getArea() : event.target.getGeometry().getLength();
		
		  var measurementFormatted = measurement > 100 ? (measurement / 1000).toFixed(2) + 'km' : measurement.toFixed(2) + 'm';
		  //debugger;
		  //resultElement.html(measurementFormatted + html);
	    });
	  });
		
	  olMap.addInteraction(measuringTool);
	};
	
	//enableMeasuringTool();
});