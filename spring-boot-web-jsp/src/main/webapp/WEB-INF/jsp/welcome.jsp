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
<link rel="stylesheet" type="text/css" href="js/ol3-sidebar.css" />


<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link type="text/css" rel="stylesheet" href="js/leaflet.css" />
<link type="text/css" rel="stylesheet" href="js/leaflet-mouseposition.css" />
<link rel="stylesheet" href="js/L.Control.Zoomslider.css" />
<link rel="stylesheet" href="js/leaflet-measure.css" />
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


/**
 * The zoomslider in the second map shall be placed between the zoom-in and
 * zoom-out buttons.
 */ 
.olMap .ol-zoom {
  right: .5em;
  left: auto;
}
.olMap .ol-zoom .ol-zoom-out {
  margin-top: 204px;
}
.olMap .ol-zoomslider {
  right: .5em;
  left: auto;
  background-color: transparent;
  top: 2.3em;
}

.olMap .ol-touch .ol-zoom .ol-zoom-out {
  margin-top: 212px;
}
.olMap .ol-touch .ol-zoomslider {
  top: 2.75em;
}

.olMap .ol-zoom-in.ol-has-tooltip:hover [role=tooltip],
.olMap .ol-zoom-in.ol-has-tooltip:focus [role=tooltip] {
  top: 3px;
}

.olMap .ol-zoom-out.ol-has-tooltip:hover [role=tooltip],
.olMap .ol-zoom-out.ol-has-tooltip:focus [role=tooltip] {
  top: 232px;
}

</style>

<script type="text/javascript">
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
		"URL": "http://59.6.157.153:9090/maps"
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
		"URL": "http://59.6.157.153:9090/maps"
	}];
</script>
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
	    		<!-- START OF SIDEBAR DIV -->
			    <div id="sidebar" class="sidebar collapsed" style="display: none">
			        <!-- Nav tabs -->
			        <div class="sidebar-tabs">
			            <ul role="tablist">
			                <li><a href="#home" role="tab"><i class="fa fa-bars"></i></a></li>
			                <li><a href="#profile" role="tab"><i class="fa fa-user"></i></a></li>
			                <li class="disabled"><a href="#messages" role="tab"><i class="fa fa-envelope"></i></a></li>
			                <li><a href="https://github.com/Turbo87/sidebar-v2" role="tab" target="_blank"><i class="fa fa-github"></i></a></li>
			            </ul>
			
			            <ul role="tablist">
			                <li><a href="#settings" role="tab"><i class="fa fa-gear"></i></a></li>
			            </ul>
			        </div>
			
			        <!-- Tab panes -->
			        <div class="sidebar-content">
			            <div class="sidebar-pane" id="home">
			                <h1 class="sidebar-header">
			                    sidebar-v2
			                    <span class="sidebar-close"><i class="fa fa-caret-left"></i></span>
			                </h1>
			
			                <p>A responsive sidebar for mapping libraries like <a href="http://leafletjs.com/">Leaflet</a> or <a href="http://openlayers.org/">OpenLayers</a>.</p>
			
			                <p class="lorem">Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p>
			
			                <p class="lorem">Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p>
			
			                <p class="lorem">Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p>
			
			                <p class="lorem">Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.</p>
			            </div>
			
			            <div class="sidebar-pane" id="profile">
			                <h1 class="sidebar-header">Profile<span class="sidebar-close"><i class="fa fa-caret-left"></i></span></h1>
			            </div>
			
			            <div class="sidebar-pane" id="messages">
			                <h1 class="sidebar-header">Messages<span class="sidebar-close"><i class="fa fa-caret-left"></i></span></h1>
			            </div>
			
			            <div class="sidebar-pane" id="settings">
			                <h1 class="sidebar-header">Settings<span class="sidebar-close"><i class="fa fa-caret-left"></i></span></h1>
			            </div>
			        </div>
			    </div>
			    <!-- END OF SIDEBAR DIV -->
	    	
				<div class="olMap" id="olMap"></div>
			</div>
			<div class="col-sm-6" style="border-right: 1px solid;">
				<div class="leafletMap" id="letMap"></div>
			</div>
	  	</div>

	</div>
	<!-- /.container -->
	<script type="text/javascript" src="js/jquery-3.3.1.min.js"></script>
	<script type="text/javascript" src="webjars/bootstrap/3.3.7/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/ol.js"></script>
	<script type="text/javascript" src="js/ol-ext.js"></script>
	<script type="text/javascript" src="js/ol3-sidebar.js"></script>
	
	<script type="text/javascript" src="js/leaflet.js"></script>
	<script type="text/javascript" src="js/leaflet-wmts.js"></script>
	<script type="text/javascript" src="js/leaflet-mouseposition.js"></script>
	<script src='https://unpkg.com/leaflet-image@latest/leaflet-image.js'></script>
	<script src="js/L.Control.Zoomslider.js" ></script>
	
	<script src="js/leaflet-geometryutil.js" ></script>
	
	<script src="js/leaflet-measure.js" ></script>
	
	<script src='js/map/ol-map.js'></script>
	<script src='js/map/leaflet-map.js'></script>
	
	<!-- 
	<div id='images'></div>
	<a id="image-download" download="map.png"></a>
	 -->
</body>
</html>
