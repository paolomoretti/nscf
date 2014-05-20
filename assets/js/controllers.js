// Generated by CoffeeScript 1.6.3
var Event, Events, Header, Home, Login, Main;

Main = function($scope, $rootElement) {
  return $scope.$on("$routeChangeStart", function(next, current) {
    return $rootElement.attr("class", current.$$route.controller.toLowerCase());
  });
};

Header = function($scope, $location) {
  $scope.filterName = "nooo";
  $scope.description = "Molte proposte per passare il tempo nel Nord-Est. Sfruttate al meglio il vostro tempo libero...";
  return $scope.getActiveSection = function() {
    if ($location.$$url.indexOf("/events/filter/" === 0)) {
      return $location.$$url.split("/events/filter/")[1];
    }
  };
};

Home = function($scope, $http) {
  $scope.loading = true;
  $scope.loadingProvince = false;
  $scope.filterName = "";
  $scope.getEvents = function() {
    if (Nscf.events != null) {
      $scope.events = Nscf.events;
      return $scope.loading = false;
    } else {
      return $http.get(Nscf.apiUrl + "events/today").success(function(data) {
        if ($scope.filterName === "") {
          $scope.events = data;
        }
        Nscf.events = data;
        return $scope.loading = false;
      });
    }
  };
  if (Nscf.province != null) {
    $scope.province = Nscf.province;
  } else {
    $scope.loadingProvince = true;
    $http.get(Nscf.apiUrl + "/province").success(function(data) {
      $scope.province = data;
      Nscf.province = data;
      return $scope.loadingProvince = false;
    });
  }
  $scope.setFilterProvincia = function($event, id, name) {
    $scope.loading = true;
    if ($scope.filterName === name) {
      $scope.filterName = "";
      return $scope.getEvents();
    } else {
      $scope.filterName = name;
      return $http.get(Nscf.apiUrl + "/provincia&id=" + id).success(function(data) {
        $scope.events = data;
        return $scope.loading = false;
      });
    }
  };
  return $scope.getEvents();
};

Events = function($scope, $routeParams, $http, $rootScope) {
  $scope.loading = true;
  $scope.filter = $routeParams.filterType != null ? $routeParams.filterType : false;
  $rootScope.$broadcast("set:events:filter", "oggi");
  if ($scope.filter === "oggi") {
    return $http.get(Nscf.apiUrl + "/events/filter&type=" + $scope.filter).success(function(data) {
      $scope.events = data;
      return $scope.loading = false;
    });
  }
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

Login = function($scope) {
  return false;
};
