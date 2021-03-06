// Generated by CoffeeScript 1.6.3
var Event, Events, Footer, Header, Home, Login, Main;

Main = function($scope, $rootScope, $rootElement, $route) {
  $scope.updateCurrentSection = function(current) {
    $scope.activeSection = (current != null) && (current.params.filterType != null) ? current.params.filterType : "home";
    if ((current != null) && current.$$route.controller === "Events.Nearby") {
      return $scope.activeSection = "nearby";
    }
  };
  $rootElement.on("keydown", function(event) {
    if (event.which === 37) {
      $rootScope.$broadcast("event:key:left");
    }
    if (event.which === 38) {
      $rootScope.$broadcast("event:key:up");
    }
    if (event.which === 39) {
      $rootScope.$broadcast("event:key:right");
    }
    if (event.which === 40) {
      $rootScope.$broadcast("event:key:down");
    }
    if (event.which === 27) {
      $rootScope.$broadcast("event:key:esc");
    }
    if (event.which === 13) {
      return $rootScope.$broadcast("event:key:enter");
    }
  });
  $scope.$on("$routeChangeStart", function(prev, current) {
    $scope.updateCurrentSection(current);
    if (current.$$route.controller != null) {
      return $rootElement.attr("class", current.$$route.controller.toLowerCase());
    }
  });
  $scope.$on("event:open", function(_event, evento) {
    $("html").addClass("has-event-open");
    $scope.currentEvent = evento;
    return $rootScope.$broadcast("currentevent:update", evento);
  });
  $scope.$on("event:close", function() {
    $("html").removeClass("has-event-open");
    return $scope.currentEvent = false;
  });
  return $scope.updateCurrentSection($route.current);
};

Header = function($scope, $element, $rootScope, $location, $http, $q) {
  $(".main-region").css("padding-top", $(".header-region").outerHeight());
  $scope.searching = false;
  $scope.searchResults = [];
  $scope.$on("event:key:down", function() {
    if ($scope.searchResults.length > 0) {
      return $scope.highlightResults(1);
    }
  });
  $scope.$on("event:key:up", function() {
    if ($scope.searchResults.length > 0) {
      return $scope.highlightResults(-1);
    }
  });
  $scope.$on("event:key:esc", function() {
    return $scope.searchResults = [];
  });
  $scope.$on("event:key:enter", function() {
    $element.find(".search-result.selected .event-item").trigger("click");
    return $rootScope.$broadcast("search:results:reset");
  });
  $scope.$on("search:results:hide", function() {
    return $scope.searchResults = [];
  });
  $scope.$on("search:results:reset", function() {
    $scope.$emit("search:results:hide");
    return $element.find("input.events-search").val("");
  });
  $scope.doSearch = function(event) {
    var _ref;
    if ($(event.target).val().trim() === "") {
      return $scope.searchResults = [];
    }
    if ((_ref = event.which) !== 13 && _ref !== 27 && _ref !== 37 && _ref !== 38 && _ref !== 39 && _ref !== 40) {
      return $scope.searchResults = $scope.getResults($(event.target).val().trim());
    }
  };
  $scope.highlightResults = function(dir) {
    var elemPos, selected, st;
    selected = $element.find(".search-result.selected").size() > 0 ? $element.find(".search-result.selected")[dir === 1 ? "next" : "prev"]() : $element.find(".search-result:first");
    if (selected.is(".search-result")) {
      $element.find(".search-result.selected").removeClass("selected");
      if (selected.is(".search-result")) {
        selected.addClass("selected");
      }
      elemPos = $element.find(".search-results").scrollTop() + selected.position().top;
      st = ($element.height() + elemPos) - $element.find(".search-results").height();
      return $element.find(".search-results").animate({
        scrollTop: st
      }, 200);
    }
  };
  $scope.getResults = function(k) {
    if ($scope.canceler != null) {
      $scope.canceler.resolve();
    }
    $scope.canceler = $q.defer();
    $scope.searching = true;
    return $http({
      method: "GET",
      url: Nscf.apiUrl + "events/search/" + k,
      timeout: $scope.canceler.promise
    }).success(function(data) {
      $scope.searching = false;
      return $scope.searchResults = data;
    });
  };
  return $scope.onLogoClicked = function(event) {
    event.preventDefault();
    $rootScope.$broadcast("event:close");
    return $location.path("/");
  };
};

Footer = function() {
  return $(".main-region").css("padding-bottom", $(".footer-region").height());
};

Home = function($scope, $http) {
  $scope.loading = true;
  $http.get(Nscf.apiUrl + "events/today").success(function(data) {
    $scope.events = data;
    return $scope.loading = false;
  });
  $("html").addClass("main-view-static");
  $(".center-view").height($(".main-view").height());
  return $(".side-view").height($(".main-view").height());
};

Login = function($scope) {
  return false;
};

Events = function($scope, $routeParams, $http) {
  var mainRegionHeight;
  $scope.loading = true;
  $http.get(Nscf.apiUrl + "events/filter/" + $scope.activeSection).success(function(data) {
    $scope.events = data;
    return $scope.loading = false;
  });
  $(".events-container .nav-tabs a").click(function(event) {
    event.preventDefault();
    return $(this).tab("show");
  });
  $("html").addClass("main-view-static");
  mainRegionHeight = $(".main-view").height();
  $(".events-container .tab-content").height(mainRegionHeight - $(".events-container .nav-tabs").outerHeight());
  return $(".side-view").height(mainRegionHeight);
};

Events.Nearby = function($scope, $timeout, $http, $categories) {
  var boundaries, defaultZoom,
    _this = this;
  defaultZoom = 10;
  boundaries = false;
  $scope.showLoading = function(action) {
    return $(".nearby-container .loading").html(action).css("opacity", 1).show();
  };
  $scope.stopLoading = function() {
    $(".nearby-container .loading").html("Caricamento...").css("opacity", 0);
    return setTimeout(function() {
      return $(".nearby-container .loading").hide();
    }, 500);
  };
  $scope.showLoading("Caricamento mappa");
  $scope.$categories = $categories;
  $scope.markers = {};
  $scope.filters = {
    categories: []
  };
  $scope.$watch("filters", function() {
    $scope.showLoading("Applico i filtri ...");
    return $timeout(function() {
      return $scope.applyFilters();
    }, 50);
  }, true);
  $scope.$on("events:listsingle:finish", function() {
    $scope.map.fitBounds(boundaries);
    return $scope.stopLoading();
  });
  $scope.$on("event:open", function(_ev, evento) {
    var eventBounds;
    eventBounds = new google.maps.LatLngBounds();
    eventBounds.extend($scope.markers[evento.id].latLng);
    $scope.map.panTo($scope.markers[evento.id].latLng);
    return $scope.map.setZoom(13);
  });
  $scope.$on("event:close", function() {
    $scope.map.setZoom(defaultZoom);
    return $scope.map.fitBounds(boundaries);
  });
  $scope.init = function() {
    var _this = this;
    $scope.action = "Caricamento eventi ...";
    if (navigator.geolocation != null) {
      return navigator.geolocation.getCurrentPosition(function(position) {
        return $scope.initMap(position);
      });
    } else {
      return $scope.initMap({
        coords: {
          latitude: 45.953656,
          longitude: 12.502205
        }
      });
    }
  };
  $scope.initMap = function(position) {
    $scope.createMap(position);
    return $scope.getEvents(function() {
      return $scope.populateMap();
    });
  };
  $scope.applyFilters = function() {
    var category, ev, resultEvents, _evs, _i, _len, _ref;
    resultEvents = [];
    if ($scope.filters.categories.length > 0) {
      _ref = $scope.filters.categories;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        category = _ref[_i];
        _evs = (function() {
          var _j, _len1, _ref1, _results;
          _ref1 = $scope._events;
          _results = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            ev = _ref1[_j];
            if (ev[category] === true) {
              _results.push(ev);
            }
          }
          return _results;
        })();
        resultEvents = resultEvents.concat(_evs);
      }
    } else {
      resultEvents = $scope._events;
    }
    $scope.events = resultEvents;
    return $scope.populateMap();
  };
  $scope.createMap = function(position) {
    var options, whereAmI;
    whereAmI = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
    options = {
      zoom: defaultZoom,
      center: whereAmI,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    $scope.map = new google.maps.Map($("#map")[0], options);
    boundaries = new google.maps.LatLngBounds();
    return new google.maps.Marker({
      position: whereAmI,
      map: $scope.map,
      icon: '/assets/images/markers/nscf.svg',
      title: "Sei qui!"
    });
  };
  $scope.getEvents = function(callback) {
    var _this = this;
    return $http.get(Nscf.apiUrl + "events/today").success(function(data) {
      $scope.events = $scope._events = data;
      return callback();
    });
  };
  $scope.populateMap = function() {
    var ev, eventLatLng, gps, marker, _i, _len, _ref;
    $scope.removeMarkers();
    $scope.action = "Caricamento eventi ...";
    if (($scope.events != null) && $scope.events.length > 0) {
      _ref = $scope.events;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        ev = _ref[_i];
        gps = ev.GPS_L.split(",");
        eventLatLng = new google.maps.LatLng(parseFloat(gps[0]), parseFloat(gps[1]));
        boundaries.extend(eventLatLng);
        marker = new google.maps.Marker({
          position: eventLatLng,
          map: $scope.map,
          icon: $scope.getMarkerIcon(ev),
          evento: ev,
          latLng: eventLatLng
        });
        google.maps.event.addListener(marker, 'click', function() {
          var infowindow;
          infowindow = new google.maps.InfoWindow;
          infowindow.setContent('<h3>' + this.evento.nome + '</h3>');
          return infowindow.open($scope.map, this);
        });
        $scope.markers[ev.id] = marker;
      }
      return $scope.stopLoading();
    }
  };
  $scope.getMarkerIcon = function(ev) {
    var cat, cats, name;
    cats = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = $categories.length; _i < _len; _i++) {
        cat = $categories[_i];
        if (ev[cat.id] !== false) {
          _results.push(cat.id.toLowerCase());
        }
      }
      return _results;
    })();
    name = cats.length > 1 ? "nscf" : cats[0];
    return '/assets/images/markers/' + name + '.svg';
  };
  $scope.removeMarkers = function() {
    var id, marker, _ref;
    _ref = $scope.markers;
    for (id in _ref) {
      marker = _ref[id];
      marker.setMap(null);
    }
    return $scope.markers = {};
  };
  return $(".nearby-container .events-container").height($(".main-view").height() - $(".nearby-container .events-container").position().top);
};

Events.ListSingle = function($rootScope, $element, $scope) {
  if ($scope.$last === true) {
    $rootScope.$broadcast("events:listsingle:finish");
  }
  $scope.init = function(ev) {
    return $scope.event = ev;
  };
  $scope.getEventImage = function() {
    return Nscf.apiUrl + "events/" + $scope.event.id + "/image";
  };
  $scope.openEvent = function() {
    if ($element.hasClass("active") === false) {
      $scope.$emit("event:open", $scope.event);
      $element.addClass("active");
    } else {
      $scope.$emit("event:close", $scope.event);
      $element.removeClass("active");
    }
    return false;
  };
  return $element.find(".event-social a").on("click", function(event) {
    return event.stopPropagation();
  });
};

Event = function($scope, $routeParams, $http) {
  $scope.loading = true;
  $http.get(Nscf.apiUrl + "/event&id=" + $routeParams.id).success(function(data) {
    $scope.ev = data;
    return $scope.loading = false;
  });
  return $scope.getDay = function(data) {
    return data.split("/")[0];
  };
};

Event.Details = function($scope, $element) {
  $scope.event = false;
  $scope.$on("currentevent:update", function(_event, evento) {
    $scope.event = evento;
    return $scope.createMap();
  });
  $scope.toggleExpandPoster = function(event) {
    event.preventDefault();
    return $element.toggleClass("has-poster-expanded");
  };
  $scope.hasLuogoSocial = function() {
    return $scope.event.luogo_facebook !== '' || $scope.event.luogo_twitter !== '' || $scope.event.luogo_googleplus !== '' || $scope.event.luogo_foursquare !== '' || $scope.event.luogo_myspace !== '';
  };
  $scope.getEventImage = function() {
    return Nscf.apiUrl + "events/" + $scope.event.id + "/image";
  };
  return $scope.createMap = function() {
    var eventLatlng, gps, options;
    gps = $scope.event.GPS_L.split(",");
    eventLatlng = new google.maps.LatLng(gps[0], gps[1]);
    options = {
      zoom: 10,
      center: eventLatlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    $scope.map = new google.maps.Map($element.find("#map")[0], options);
    return new google.maps.Marker({
      position: eventLatlng,
      map: $scope.map,
      title: $scope.event.nome
    });
  };
};
