
Main = ($scope, $rootScope, $rootElement, $route)->

  $scope.updateCurrentSection = (current)->
    $scope.activeSection = if current? and current.params.filterType? then current.params.filterType else "home"


  $scope.$on "$routeChangeStart", (prev, current)->
    $scope.updateCurrentSection current
    $rootElement.attr "class", current.$$route.controller.toLowerCase()

  $scope.$on "event:open", (_event, evento)->
    $("html").addClass "has-event-open"
    $scope.currentEvent = evento

    $rootScope.$broadcast "currentevent:update", evento

  $scope.$on "event:close", (_event, evento)->
    $("html").removeClass "has-event-open"
    $scope.currentEvent = false


  $scope.updateCurrentSection $route.current

#-----------------------------------------------------------------------------------------------------------------------

Header = ->
  $(".main-region").css "padding-top", $(".header-region").outerHeight()

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
  $(".events-container .tab-content").height $(".main-view").height()-$(".events-container .nav-tabs").outerHeight()


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
    true


#-----------------------------------------------------------------------------------------------------------------------


EventDetails = ($scope)->

  $scope.event = false

  $scope.$on "currentevent:update", (_event, evento)->
    console.log "EventDetails", evento
    $scope.event = evento


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
