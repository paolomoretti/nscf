###
  Aggiungendo l'attributo icon a un elemento, aggiunge l'icona a sinistra
  Il valore di icon e' preso da http://getbootstrap.com/components/#glyphicons, togliendo i riferimenti a glyphicon
  Es: <p icon=euro"">Euro</p> => Stampera' un scritta euro preceduta dal simbolo euro
###
Nscf.directive "icon", ->
  link: (scope, element, attrs)->
    attrs.$observe 'icon', (iconName)->
      element.prepend $('<span class="glyphicon glyphicon-'+iconName.toLowerCase()+'"></span>')