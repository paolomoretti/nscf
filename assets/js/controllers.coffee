
Main = ($scope, $rootElement)->
  $scope.$on "$routeChangeStart", (next, current)->
    $rootElement.attr "class", current.$$route.controller.toLowerCase()

#-----------------------------------------------------------------------------------------------------------------------

Header = ($scope, $location)->
  $scope.filterName = "nooo"

  $scope.description = "Molte proposte per passare il tempo nel Nord-Est. Sfruttate al meglio il vostro tempo libero..."

  $scope.getActiveSection = ->
    return $location.$$url.split("/events/filter/")[1] if $location.$$url.indexOf "/events/filter/" is 0

  $(".main-region").css "padding-top", $(".header-region").outerHeight()

#-----------------------------------------------------------------------------------------------------------------------

Footer = ->
  $(".main-region").css "padding-bottom", $(".footer-region").height()

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
      $http.get(Nscf.apiUrl + "events/today").success (data)->
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

  $scope.getDay = (data)->
    data.split("/")[0]

#-----------------------------------------------------------------------------------------------------------------------

Login = ($scope)->
  false

#-----------------------------------------------------------------------------------------------------------------------
