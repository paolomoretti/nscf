// Generated by CoffeeScript 1.6.3
/*
  Aggiungendo l'attributo icon a un elemento, aggiunge l'icona a sinistra
  Il valore di icon e' preso da http://fortawesome.github.io/Font-Awesome/icons/
  Es: <p icon="facebook">Facebook</p> => Stampera' un scritta facebook preceduta dal simbolo di facebook
*/

Nscf.directive("icon", function() {
  return {
    link: function(scope, element, attrs) {
      return attrs.$observe('icon', function(iconName) {
        return element.prepend($('<span class="fa fa-' + iconName.toLowerCase() + ' mrs"></span>'));
      });
    }
  };
});

Nscf.directive("date", function() {
  return {
    link: function(scope, element, attrs) {
      return attrs.$observe('date', function(date) {
        var myDate;
        element.empty();
        myDate = moment(date, "DD-MM-YYYY").lang("it");
        element.append($('<span class="dd">' + myDate.format('ddd') + '</span>'));
        element.append($('<span class="gg">' + myDate.format('D') + '</span>'));
        element.append($('<span class="mm">' + myDate.format('MMM') + '</span>'));
        return element.addClass("date");
      });
    }
  };
});
