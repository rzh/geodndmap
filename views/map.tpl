<!-- original example from https://developers.google.com/maps/documentation/javascript/examples/layer-data-dragndrop -->
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
    <title>Drag and Drop GeoJSON</title>
    <!-- Latest compiled and minified CSS -->
    <link rel="stylesheet" href="http://localhost:8080/static/bootstrap/css/bootstrap.min.css">
    <script src="http://localhost:8080/static/jquery-2.1.1.min.js" > </script>
    <script src="http://localhost:8080/static/bootstrap/js/bootstrap.min.js"></script>

    <style type="text/css">
      html { height: 100% }
      body { height: 100%; margin: 0; padding: 0; overflow: hidden; }
      #map-canvas { height: 100% }
      #drop-container {
        display: none;
        height: 100%;
        width: 100%;
        position: absolute;
        z-index: 1;
        top: 0px;
        left: 0px;
        padding: 20px;
        background-color: rgba(100, 100, 100, 0.5);
      }
      #drop-silhouette {
        color: white;
        border: white dashed 8px;
        height: calc(100% - 56px);
        width: calc(100% - 56px);
        background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAYAAABw4pVUAAAAAXNSR0IArs4c6QAAAAZiS0dEAGQAZABkkPCsTwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB90LHAIvICWdsKwAAAAZdEVYdENvbW1lbnQAQ3JlYXRlZCB3aXRoIEdJTVBXgQ4XAAACdklEQVR42u3csU7icBzA8Xp3GBMSeRITH8JHMY7cRMvmVmXoE9TAcJubhjD4ApoiopgqDMWAKAgIcSAiCfxuwhwROVJbkPD9rP23ob8vpZCQKgoAAAAAAAAAAPDYyiK/eNM05bNtr6+vSjgcXiHxDMkE1WpVFvGcfpCVICAIQUAQgoAgBAFBCAKCgCAEAUEIAoIQBAQhCAgCghAEBCEICEIQEIQgIAgIQhAQhCAgCEFAEIKAICAIQUAQgoAgBAFBCDIzhmFINBo9/K6D0XVddnd3ZaneDY7jSCqVcn3SfjyeKRKJbJ2dnYllWbKUl2i5XJaXlxdJJBIy7yDHx8fy9vYm6XR6OWMM3d/fi4hIqVSSWCwmsw5ycHAgrVZLRETOz8+XO8ZQpVJ5H2Y6nRZN0/b9DqLruhSLxfd9MpkMMT6L0uv1JJlMih9BhveJwWDwvv7i4oIY4zw8PIwMtt1uSzweF6+CHB0dSbfbHVmbzWaJMcnj4+OHAd/d3cne3p64DWKapjw/P39Yd3l5SYxpVKvVsYO2LEtUVd2ZNoiu6+I4ztg1V1dXxPAiSq/Xk5OTk0k9pNVqyenp6ch94l+5XI4YbtRqNfHa9fX1t43xcwGa/Nnc3PwdDAY9OZht28rGxgZPvP6KSCSy9fT09OUrw7ZtPqa8jFKv113HuLm5IYbXVFXdcRPl9vaWGH5GaTQaU8fI5/PE8JumafvNZvO/MQqFAjFmJRqNHk6Ksqgx5vr1zzAM2d7edr3/6uqqsra2NnZbp9NR+v2+62OHQqG5zObXPIMEAgFlfX3dl2N79btl1viTA0FAEIKAIAQBAAAAAAAAsMz+Ai1bUgo6ebm8AAAAAElFTkSuQmCC');
        background-repeat: no-repeat;
        background-position: center;
      }
    </style>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCa7ka1f8uuNJc-xrTsZu-uKjpcfndTGwE&v=3.exp"></script>
    <script type="text/javascript">

var map;
var bounds;
var stage=1;

function initMap() {
  // set up the map
  map = new google.maps.Map(document.getElementById('map-canvas'), {
    center: new google.maps.LatLng(0, 0),
    zoom: 2
  });
  // set up the bounds
  bounds = new google.maps.LatLngBounds();
}

/** 
 * converts arrays (of arrays (of arrays)) of coordinate pairs to LatLng objects. 
 * also updates the bounds for map auto-fit
 **/
function coord2LatLng(arr, depth) {
  if (depth === 0) {
    // for Point
    var p = new google.maps.LatLng(arr[1], arr[0]);
    bounds.extend(p);
    return p;
  }
  if (depth === 1) {
    // for LineString
    return arr.map(function (c) {
      var p = new google.maps.LatLng(c[1], c[0]);
      bounds.extend(p);
      return p;
    });
  }
  if (depth === 2) {
    // for MultiLineString, Polygon
    var paths = [];
    arr.forEach(function (path) {
      paths.push(path.map(function (coords) {
        var p = new google.maps.LatLng(coords[1], coords[0]);
        bounds.extend(p);
        return p;
      }));
    });
    return paths;
  }
}


/** 
 * load GeoJSON string or object and render shape on map
 **/
function loadGeoJson(geo) {
  if (typeof geo === 'string') {
    geo = JSON.parse(geo);
  }
  if (geo.type.toLowerCase() === 'polygon') {
    var polygon = new google.maps.Polygon({
      map: map,
      paths: coord2LatLng(geo.coordinates, 2),
      strokeColor: '#FF0000',
      strokeOpacity: 0.8,
      strokeWeight: 2,
      fillColor: '#FF0000',
      fillOpacity: 0.30,
      geodesic: true,
      draggable: true
    });
  } else if (geo.type.toLowerCase() === 'linestring') {
    var polyline = new google.maps.Polyline({
      map: map,
      path: coord2LatLng(geo.coordinates, 1),
      strokeColor: '#FF0000',
      strokeOpacity: 0.8,
      strokeWeight: 2,
      geodesic: true
    });
  } else if (geo.type.toLowerCase() === 'point') {
    var marker = new google.maps.Marker({
      map: map,
      position: coord2LatLng(geo.coordinates, 0)
    });
  } else if (geo.type.toLowerCase() === 'multipoint') {
    var points = coord2LatLng(geo.coordinates, 1);
    points.forEach(function (point) {
      var marker = new google.maps.Marker({
        map: map,
        position: point
      });
    });
  } else if (geo.type.toLowerCase() === 'geometrycollection') {
    geo.geometries.forEach(loadGeoJson);
  }
}


/**
 * DOM (drag/drop) functions 
 **/
function initEvents() {
  // set up the drag & drop events
  var mapContainer = document.getElementById('map-canvas');
  var dropContainer = document.getElementById('drop-container');

  // first on common events
  [mapContainer, dropContainer].forEach(function(container) {
    container.addEventListener('drop', handleDrop, false);
    container.addEventListener('dragover', showPanel, false);
  });

  // then map-specific events
  mapContainer.addEventListener('dragstart', showPanel, false);
  mapContainer.addEventListener('dragenter', showPanel, false);

  // then the overlay specific events (since it only appears once drag starts)
  dropContainer.addEventListener('dragend', hidePanel, false);
  dropContainer.addEventListener('dragleave', hidePanel, false);
}

function showPanel(e) {
  e.stopPropagation();
  e.preventDefault();
  document.getElementById('drop-container').style.display = 'block';
  return false;
}

function hidePanel(e) {
  document.getElementById('drop-container').style.display = 'none';
}

function handleDrop(e) {
  e.preventDefault();
  e.stopPropagation();
  hidePanel(e);

  var files = e.dataTransfer.files;
  if (files.length) {
    // process file(s) being dropped
    // grab the file data from each file
    for (var i = 0, file; file = files[i]; i++) {
      var reader = new FileReader();
      reader.onload = function(e) {
        loadGeoJson(e.target.result);
        map.fitBounds(bounds);
      };
      reader.onerror = function(e) {
        console.error('reading failed');
      };
      reader.readAsText(file);
    }
  } else {
    // process non-file (e.g. text or html) content being dropped
    // grab the plain text version of the data
    var plainText = e.dataTransfer.getData('text/plain');
    if (plainText) {
      loadGeoJson(plainText);
      map.fitBounds(bounds);
    }
  }

  // prevent drag event from bubbling further
  return false;
}

google.maps.event.addDomListener(window, 'load', function() {
  initMap();
  initEvents();

  $('#query').on('click', function(event) {
    $.getJSON( "geoQuery", {query: '{}'}, function( data ) {
      $( "#queryStr" ).val( JSON.stringify(data) );
           // parse and update map
           data.forEach(function(d) {
            plainText = JSON.stringify(d)
                if (plainText) {
                    loadGeoJson(plainText);
                    map.fitBounds(bounds);
                }
            });
        });
  })

  // init even 
  $('#decStage').on('click', function(event) {
      if(stage > 1) {
        stage--;
      }
      $('#stage').text(stage);
  })

  $('#incStage').on('click', function(event) {
      if(stage < 10) {
        stage++
      }
      $('#stage').text(stage);
  })
});

    </script>
  </head>
  <body>
    <h4>Geo Query</h4>
    <textarea id="queryStr" class="form-control" rows="3"></textarea>

    <button id="query" type="submit" class="btn btn-default">Submit <span class="glyphicon glyphicon-map-marker"/></button>
    
    <div class="pull-right">
    <button id="decStage" class="btn btn-default"> 
        <span class="glyphicon glyphicon-chevron-left"></span> 
    </button>
    Stage: <span id="stage"> 1 </span>
    <button id="incStage" class="btn btn-default"> 
        <span class="glyphicon glyphicon-chevron-right"></span>
    </button>
    </div>


    <div id="map-canvas"></div>

    <div id="drop-container"><div id="drop-silhouette"></div></div>
  </body>
</html>
