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