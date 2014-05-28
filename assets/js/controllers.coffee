
Main = ($scope, $rootScope, $rootElement, $route)->

  $scope.updateCurrentSection = (current)->
    $scope.activeSection = if current? and current.params.filterType? then current.params.filterType else "home"

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


SingleEventList = ($rootScope, $element, $scope)->

  $scope.init = (ev)->
    $scope.event = ev

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


EventDetails = ($scope, $element)->

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



#-----------------------------------------------------------------------------------------------------------------------

Event = ($scope, $routeParams, $http)->
  $scope.loading = true

  $http.get(Nscf.apiUrl + "/event&id="+$routeParams.id).success (data)->
    $scope.ev = data
    $scope.loading = false

  $scope.getDay = (data)->
    data.split("/")[0]

#-----------------------------------------------------------------------------------------------------------------------

Login = ($scope)->
  false

#-----------------------------------------------------------------------------------------------------------------------
