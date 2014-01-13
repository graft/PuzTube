@puztubeApp.factory 'Topic', [ '$http', ->
  @update_obj = (topic) =>
    $.extend @, topic

  @add_workspace = (workspace) => @workspaces.push workspace

  @update_workspace = (workspace) =>
    $.extend(w, workspace) for w in @workspaces when w.id == workspace.id

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
    Workspaces.process msg.workspace
    Topic.add_workspace msg.workspace

  socket.on 'update workspace', (msg) ->
    console.log "Updating workspace"
    Workspaces.process msg.workspace
    Topic.update_workspace msg.workspace

  $scope.topic = Topic
  $scope.workspaces = Workspaces

  $scope.valid_workspaces = [ 'text' ]

  Workspaces.thread = Topic
  Workspaces.thread_type = 'Topic'

  $scope.request_topic = ->
    $http.post(Routes.get_topic_path channel)
      .success (topic) -> 
        Topic.update_obj topic
        for w in Topic.workspaces
          Workspaces.process w


  $scope.add_workspace = -> $scope.adding_workspace = true

  $scope.cancel_workspace = -> $scope.adding_workspace = false

  $scope.request_topic()

