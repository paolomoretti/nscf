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
      templateUrl: "assets/templates/events/page.html"
      controller: "Events"

    $routeProvider.when "/events/nearby",
      templateUrl: "assets/templates/events/nearby.html"
      controller: "Events.Nearby"


    # Static pages
    for section in ['info', 'contatti']
      $routeProvider.when "/" + section,
        templateUrl: "assets/templates/static/"+section+".html"

]

Nscf.value "$categories", [
  { name: 'Evento Musicale', id: "EM", icon: "music", color: "" }
  { name: 'Evento Sportivo', id: "ES", icon: "trophy", color: ""}
  { name: 'Fiera', id: "FI", icon: "beer", color: ""}
  { name: 'Mostra Mercato', id: "MM", icon: "eye", color: ""}
  { name: 'Spettacolo', id: "SP", icon: "university", color: ""}
  { name: 'Festa', id: "FE", icon: "users", color: ""}
]