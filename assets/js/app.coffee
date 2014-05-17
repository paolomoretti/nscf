Nscf = angular.module "Nscf", ['ngRoute']
Nscf.apiUrl = "http://dev.nonsocosafare.it/api/"

# Definisco le url da tracciare con Angular.
Nscf.config [
  "$routeProvider", ($routeProvider)->
    $routeProvider.when "/",
      templateUrl: "assets/templates/home/page.html"
      controller: "Home"

    $routeProvider.when "/login",
      templateUrl: "assets/templates/login.html"
      controller: "Login"

    # Events
    $routeProvider.when "/events/filter/:filterType",
      templateUrl: "assets/templates/events/events.html"
      controller: "Events"

    $routeProvider.when "/events/:id",
      templateUrl: "assets/templates/events/event.html"
      controller: "Event"


    # Static pages
    for section in ['info', 'contatti']
      $routeProvider.when "/" + section,
        templateUrl: "assets/templates/static/"+section+".html"

]

Main = ($scope, $rootScope)->
#  $scope.$on "$routeChangeStart", (next, current)->
#    $rootScope.$broadcast

#-----------------------------------------------------------------------------------------------------------------------

Header = ($scope, $location)->
  $scope.filterName = "nooo"

  $scope.description = "Molte proposte per passare il tempo nel Nord-Est. Sfruttate al meglio il vostro tempo libero..."

#  $scope.$on "$routeChangeStart", (next, current)->
#    $scope.filterName = current.params.filterType if current.params.filterType?
#
#  $scope.filterName = $routeParams.filterType if $routeParams.filterType?
#  console.log "$scope.filterName", $scope.filterName, $routeParams

  $scope.getActiveSection = ->
    return $location.$$url.split("/events/filter/")[1] if $location.$$url.indexOf "/events/filter/" is 0

#-----------------------------------------------------------------------------------------------------------------------

Home = ($scope, $http)->
  $scope.loading = true
  $scope.loadingProvince = false
  $scope.filterName = ""

  $scope.getEvents = ->
    if Nscf.events?
      $scope.events = Nscf.events
      $scope.loading = false
    else
      $http.get(Nscf.apiUrl + "events").success (data)->
        $scope.events = data if $scope.filterName is ""
        Nscf.events = data
        $scope.loading = false

  if Nscf.province? then $scope.province = Nscf.province else
    $scope.loadingProvince = true
    $http.get(Nscf.apiUrl + "/province").success (data)->
      $scope.province = data
      Nscf.province = data
      $scope.loadingProvince = false

  $scope.setFilterProvincia = ($event, id, name)->
    $scope.loading = yes

    if $scope.filterName is name
      $scope.filterName = ""
      do $scope.getEvents

    else
      $scope.filterName = name

      $http.get(Nscf.apiUrl + "/provincia&id="+id).success (data)->
        $scope.events = data
        $scope.loading = no

  do $scope.getEvents

#-----------------------------------------------------------------------------------------------------------------------

Events = ($scope, $routeParams, $http, $rootScope)->
  $scope.loading = true
  $scope.filter = if $routeParams.filterType? then $routeParams.filterType else false

  $rootScope.$broadcast "set:events:filter", "oggi"

  if $scope.filter is "oggi"
    $http.get(Nscf.apiUrl + "/events/filter&type="+$scope.filter).success (data)->
      $scope.events = data
      $scope.loading = false


#-----------------------------------------------------------------------------------------------------------------------

Event = ($scope, $routeParams, $http)->
  $scope.loading = true

  $http.get(Nscf.apiUrl + "/event&id="+$routeParams.id).success (data)->
    $scope.ev = data
    $scope.loading = false
    console.log "$scope.ev", data


#-----------------------------------------------------------------------------------------------------------------------

Login = ($scope)->
  false

#-----------------------------------------------------------------------------------------------------------------------


Nscf.directive "icon", ->
  link: (scope, element, attrs)->
    attrs.$observe 'icon', (iconName)->
      element.prepend $('<span class="glyphicon glyphicon-'+iconName.toLowerCase()+'"></span>')