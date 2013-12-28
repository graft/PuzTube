@puztubeApp = angular.module('puztubeApp', ['ui.utils']).run ($rootScope)->
  @

@puztubeApp.directive "scrollBottom", ->
  scroll =
    link: (scope, element, attr) ->
      $(element).on "newitem", ->
        $(element).scrollTop $(element).children()[0].scrollHeight

@applyScope = (id) ->
  angular.element($(id)).scope().$apply()

@getSrv = (name, element) ->
  #element = element || '*[ng-app]'
  angular.element(document).injector().get name

