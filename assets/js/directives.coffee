###
  Aggiungendo l'attributo icon a un elemento, aggiunge l'icona a sinistra
  Il valore di icon e' preso da http://fortawesome.github.io/Font-Awesome/icons/
  Es: <p icon="facebook">Facebook</p> => Stampera' un scritta facebook preceduta dal simbolo di facebook
###
Nscf.directive "icon", ->
  link: (scope, element, attrs)->
    attrs.$observe 'icon', (iconName)->
      element.prepend $('<span class="fa fa-'+iconName.toLowerCase()+'"></span>')

#-----------------------------------------------------------------------------------------------------------------------
# Aggiungendo la directive date con il valore della data, la trasformera' in un mini calendario

Nscf.directive "date", ->
  link: (scope, element, attrs)->
    attrs.$observe 'date', (date)->
      myDate = moment(date, "DD-MM-YYYY").lang("it")
      element.append $('<span class="dd">'+myDate.format('ddd')+'</span>')
      element.append $('<span class="gg">'+myDate.format('D')+'</span>')
      element.append $('<span class="mm">'+myDate.format('MMM')+'</span>')
      element.addClass "date"