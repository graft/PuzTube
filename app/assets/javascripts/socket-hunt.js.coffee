root = exports ? this

root.Socket.hunt =
  join: (users) ->
    scope = get_scope('#hunt')
    scope.visible = true
    scope.$apply()

root.Socket.modules.push root.Socket.hunt
