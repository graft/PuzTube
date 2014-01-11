@puztubeApp.factory 'Topic', [ '$http', ->
  @update_obj = (topic) =>
    $.extend @, topic

  @add_workspace = (workspace) => @workspaces.push workspace

  @remove_workspace = (workspace) => @workspaces = (w for w in @workspaces if w.id != workspace.id)

  @
]

@puztubeApp.controller "topicController", ($scope, $http, Topic, Workspaces, socket) ->
  socket.on 'connected', (msg) ->
    $scope.visible = true

  socket.on 'update topic', (msg) ->
    console.log "Updating topic"
    Topic.update_obj msg.topic

  socket.on 'new workspace', (msg) ->
    console.log "Adding workspace"
    Topic.add_workspace msg.workspace

  $scope.topic = Topic
  $scope.workspaces = Workspaces

  $scope.valid_workspaces = [ 'text' ]

  Workspaces.thread = Topic
  Workspaces.thread_type = 'Topic'

  $scope.request_topic = ->
    $http.post(Routes.get_topic_path channel)
      .success (topic) -> Topic.update_obj topic

  $scope.add_workspace = -> $scope.adding_workspace = true
  $scope.cancel_workspace = -> $scope.adding_workspace = false

  $scope.request_topic()
