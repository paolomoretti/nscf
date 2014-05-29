
Main = ($scope, $rootScope, $rootElement, $route)->

  $scope.updateCurrentSection = (current)->
    $scope.activeSection = if current? and current.params.filterType? then current.params.filterType else "home"
    $scope.activeSection = "nearby" if current? and current.$$route.controller is "Events.Nearby"

  $rootElement.on "keydown", (event)->
    $rootScope.$broadcast "event:key:left"  if event.which is 37
    $rootScope.$broadcast "event:key:up"    if event.which is 38
    $rootScope.$broadcast "event:key:right" if event.which is 39
    $rootScope.$broadcast "event:key:down"  if event.which is 40
    $rootScope.$broadcast "event:key:esc"   if event.which is 27
    $rootScope.$broadcast "event:key:enter" if event.which is 13

  $scope.$on "$routeChangeStart", (prev, current)->
    $scope.updateCurrentSection current
    $rootElement.attr "class", current.$$route.controller.toLowerCase() if current.$$route.controller?

  $scope.$on "event:open", (_event, evento)->
    $("html").addClass "has-event-open"
    $scope.currentEvent = evento

    $rootScope.$broadcast "currentevent:update", evento

  $scope.$on "event:close", ->
    $("html").removeClass "has-event-open"
    $scope.currentEvent = false


  $scope.updateCurrentSection $route.current

#-----------------------------------------------------------------------------------------------------------------------

Header = ($scope, $element, $rootScope, $location, $http, $q)->
  $(".main-region").css "padding-top", $(".header-region").outerHeight()

  $scope.searching = false
  $scope.searchResults = []

  # Events
  $scope.$on "event:key:down", ->
    $scope.highlightResults 1 if $scope.searchResults.length > 0

  $scope.$on "event:key:up", ->
    $scope.highlightResults -1 if $scope.searchResults.length > 0

  $scope.$on "event:key:esc", ->
    $scope.searchResults = []

  $scope.$on "event:key:enter", ->
    $element.find(".search-result.selected .event-item").trigger "click"
    $rootScope.$broadcast "search:results:reset"

  $scope.$on "search:results:hide", ->
    $scope.searchResults = []

  $scope.$on "search:results:reset", ->
    $scope.$emit "search:results:hide"
    $element.find("input.events-search").val ""

  # Methods
  $scope.doSearch = (event)->
    return $scope.searchResults = [] if $(event.target).val().trim() is ""
    $scope.searchResults = $scope.getResults $(event.target).val().trim() if event.which not in [13, 27, 37, 38, 39, 40]

  $scope.highlightResults = (dir)->
    selected = if $element.find(".search-result.selected").size() > 0 then $element.find(".search-result.selected")[if dir is 1 then "next" else "prev"]() else $element.find(".search-result:first")

    if selected.is ".search-result"
      $element.find(".search-result.selected").removeClass "selected"
      selected.addClass "selected" if selected.is(".search-result")

      elemPos = $element.find(".search-results").scrollTop() + selected.position().top
      st = ($element.height() + elemPos)-$element.find(".search-results").height()
      $element.find(".search-results").animate
        scrollTop: st
      , 200

  $scope.getResults = (k)->
    do $scope.canceler.resolve if $scope.canceler?

    $scope.canceler = do $q.defer
    $scope.searching = true

    $http(method: "GET", url: Nscf.apiUrl + "events/search/" + k, timeout: $scope.canceler.promise).success (data)->
      $scope.searching = false
      $scope.searchResults = data

  $scope.onLogoClicked = (event)->
    do event.preventDefault

    $rootScope.$broadcast "event:close"
    $location.path "/"

#-----------------------------------------------------------------------------------------------------------------------

Footer = ->
  $(".main-region").css "padding-bottom", $(".footer-region").height()

#-----------------------------------------------------------------------------------------------------------------------

Home = ($scope, $http)->
  $scope.loading = true

  $http.get(Nscf.apiUrl + "events/today").success (data)->
    $scope.events = data
    $scope.loading = false

  $("html").addClass "main-view-static"
  $(".center-view").height $(".main-view").height()
  $(".side-view").height $(".main-view").height()


#-----------------------------------------------------------------------------------------------------------------------


Login = ($scope)->
  false











#----------------------------------------------------------------------------------------------------------------------
#  EVENTS
#----------------------------------------------------------------------------------------------------------------------

Events = ($scope, $routeParams, $http)->
  $scope.loading = true

  $http.get(Nscf.apiUrl + "events/filter/" + $scope.activeSection).success (data)->
    $scope.events = data
    $scope.loading = false

  $(".events-container .nav-tabs a").click (event)->
    do event.preventDefault

    $(this).tab "show"

  $("html").addClass "main-view-static"

  mainRegionHeight = $(".main-view").height()

  $(".events-container .tab-content").height mainRegionHeight-$(".events-container .nav-tabs").outerHeight()
  $(".side-view").height mainRegionHeight


#-----------------------------------------------------------------------------------------------------------------------

Events.Nearby = ($scope, $timeout, $http, $categories)->

  $scope.loading = true
  $scope.action = "Riconoscimento posizione..."
  $scope.defaultZoom = 10
  $scope.boundaries = false
  $scope.$categories = $categories
  $scope.markers = {}
  $scope.filters =
    categories: []
    event: false

  # Events
  $scope.$watch "filters", ->
    do $scope.applyFilters
  , true

  $scope.$on "events:listsingle:finish", ->
    $scope.map.fitBounds $scope.boundaries

    do $scope.stopLoading

  $scope.$on "event:open", (_ev, evento)->
    eventBounds = new google.maps.LatLngBounds()
    eventBounds.extend $scope.markers[evento.id].latLng

    $scope.map.panTo $scope.markers[evento.id].latLng
    $scope.map.setZoom 13
#    $scope.map.setCenter $scope.markers[evento.id].latLng
#    $scope.map.fitBounds eventBounds

  $scope.$on "event:close", (_ev, evento)->
    $scope.filters.event = false

  $scope.init = ->
    # Faking to be in veneto
    $scope.action = "Caricamento eventi ..."

    position =
      coords:
        latitude: 45.953656
        longitude: 12.502205

    $scope.createMap position
    $scope.getEvents ->
      $scope.populateMap()

#   TODO: Uncomment and remove fake code
#    if navigator.geolocation?
#      navigator.geolocation.getCurrentPosition (position)=>
#        $timeout ->
#          $scope.loading = false
#        , 0
#        $scope.createMap position
#        $scope.getEvents ->
#          $scope.populateMap()
#
#      , (errorMessage)->
#        alert errorMessage



  $scope.applyFilters = ->
    resultEvents = []

    # Apply single event filter
    if $scope.filters.event isnt false
      resultEvents.push $scope.filters.event

    # Apply event category filter
    else if $scope.filters.categories.length > 0
      for category in $scope.filters.categories
        _evs = (ev for ev in $scope._events when ev[category] is true)
        resultEvents = resultEvents.concat _evs

    # No filters, let's take all events
    else
      resultEvents = $scope._events

    $scope.events = resultEvents

    do $scope.populateMap

  $scope.createMap = (position)->
    whereAmI = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
    options =
      zoom      : $scope.defaultZoom
      center    : whereAmI
      mapTypeId : google.maps.MapTypeId.ROADMAP

    $scope.map = new google.maps.Map($("#map")[0], options)
    $scope.boundaries = new google.maps.LatLngBounds()

    new google.maps.Marker
      position  : whereAmI
      map       : $scope.map
      title     : "Sei qui!"

  $scope.getEvents = (callback)->
    $http.get(Nscf.apiUrl + "events").success (data)=>
      $scope.events = $scope._events = data

      callback()

  $scope.populateMap = ->
    do $scope.removeMarkers

    $scope.action = "Eventi caricati, applico i filtri ..."

    for ev in $scope.events
      gps = ev.GPS_L.split(",")

      eventLatLng = new google.maps.LatLng(parseFloat(gps[0]), parseFloat(gps[1]))

      $scope.boundaries.extend eventLatLng

      marker = new google.maps.Marker
        position  : eventLatLng
        map       : $scope.map
#        icon      :
#          path        : google.maps.SymbolPath.CIRCLE,
#          strokeColor : "red",
#          scale       : 3
#        animation : google.maps.Animation.DROP
        evento: ev
        latLng: eventLatLng

      google.maps.event.addListener marker, 'click', ->
        infowindow = new google.maps.InfoWindow

        infowindow.setContent '<h3>'+@.evento.nome+'</h3>'
        infowindow.open $scope.map, @

      $scope.markers[ev.id] = marker

  $scope.removeMarkers = ->
    for id,marker of $scope.markers
      marker.setMap null

    $scope.markers = {}

  $scope.stopLoading = ->
    $timeout ->
      $scope.loading = false
    , 500

    $timeout ->
      $(".nearby-container .loading").hide()
    , 1000

  $(".nearby-container .events-container").height $(".main-view").height() - $(".nearby-container .events-container").position().top



#-----------------------------------------------------------------------------------------------------------------------


Events.ListSingle = ($rootScope, $element, $scope)->

  $scope.init = (ev)->
    $scope.event = ev

    if $scope.$last is true then $rootScope.$broadcast "events:listsingle:finish", ev

  $scope.getEventImage = ->
    Nscf.apiUrl + "events/" + $scope.event.id + "/image"

  $scope.openEvent = ->
    if $element.hasClass("active") is false
      $scope.$emit "event:open", $scope.event
      $element.addClass "active"
    else
      $scope.$emit "event:close", $scope.event
      $element.removeClass "active"
    false

  $element.find(".event-social a").on "click", (event)->
    do event.stopPropagation


#-----------------------------------------------------------------------------------------------------------------------

Event = ($scope, $routeParams, $http)->
  $scope.loading = true

  $http.get(Nscf.apiUrl + "/event&id="+$routeParams.id).success (data)->
    $scope.ev = data
    $scope.loading = false

  $scope.getDay = (data)->
    data.split("/")[0]

#-----------------------------------------------------------------------------------------------------------------------


Event.Details = ($scope, $element)->

  $scope.event = false


  # Events
  $scope.$on "currentevent:update", (_event, evento)->
    $scope.event = evento
    do $scope.createMap

  $scope.toggleExpandPoster = (event)->
    do event.preventDefault

    $element.toggleClass "has-poster-expanded"

  # Methods
  $scope.hasLuogoSocial = ->
    $scope.event.luogo_facebook isnt '' or $scope.event.luogo_twitter isnt '' or $scope.event.luogo_googleplus isnt '' or $scope.event.luogo_foursquare isnt '' or $scope.event.luogo_myspace isnt ''

  $scope.getEventImage = ->
    Nscf.apiUrl + "events/" + $scope.event.id + "/image"

  $scope.createMap = ->
    gps = $scope.event.GPS_L.split ","
    eventLatlng = new google.maps.LatLng(gps[0], gps[1])

    options =
      zoom: 10
      center: eventLatlng
      mapTypeId: google.maps.MapTypeId.ROADMAP

    $scope.map = new google.maps.Map($element.find("#map")[0], options)

    new google.maps.Marker
      position: eventLatlng,
      map: $scope.map,
      title: $scope.event.nome


