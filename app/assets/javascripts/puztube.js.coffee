@puztubeApp = angular.module('puztubeApp', ['ui.utils']).run ($rootScope)->
  $rootScope.time_format = (time) ->
    if time < 3540
      parseInt(time/60)+' min'
    else if time < 3600
      '1 hr' # 3600 = 1 hour
    else if time < 82800
      (Math.round((time+99)/360)/10)+' hrs'
    else if time < 86400
      '1 day' # 86400 = 1 day
    else if time < 518400 
      (Math.round((time+800)/(60*6*24))/10)+' days'
    else if time < 1036800
      '1 wk'
    else
      parseInt((time+180000)/(60*60*24*7))+' wks'

  @

@puztubeApp.directive "scrollBottom", ->
  scroll =
    link: (scope, element, attr) ->
      $(element).on "newitem", ->
        $(element).scrollTop $(element).children()[0].scrollHeight

@apply_scope = (id) ->
  angular.element($(id)).scope().$apply()

@get_service = (name, id) ->
  angular.element($(id)[0] || document).injector().get name

@get_scope = (id) ->
  angular.element($(id)[0] || document).scope()

@update_window = (name) ->
  apply_scope('#'+name+'window')
