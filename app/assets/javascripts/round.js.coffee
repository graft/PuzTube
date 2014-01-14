@puztubeApp.factory 'Round', [ '$http', ->
  @update_obj = (round) =>
    $.extend @, round

  @add_workspace = (workspace) => @workspaces.push workspace

  @update_workspace = (workspace) =>
    $.extend(w, workspace) for w in @workspaces when w.id == workspace.id

  @update_workspace_cell = (workspace_id, row, col, update) =>
    for w in @workspaces
      if w.id == workspace_id
        if row == 0
          w.table_header[col].contents = update
        else
          w.table_rows[row-1][col].contents = update

  @
]

@puztubeApp.controller "roundController", ($scope, $http, Round, Workspaces, socket) ->
  socket.on 'connected', (msg) ->
    $scope.visible = true

  socket.on 'update round', (msg) ->
    console.log "Updating round"
    Round.update_obj msg.round

  socket.on 'new workspace', (msg) ->
    console.log "Adding workspace"
    Workspaces.process msg.workspace
    Round.add_workspace msg.workspace

  socket.on 'update workspace', (msg) ->
    console.log "Updating workspace"
    Workspaces.process msg.workspace
    Round.update_workspace msg.workspace

  socket.on 'update cell', (msg) ->
    console.log "Updating workspace cell"
    console.log msg
    Round.update_workspace_cell msg.workspace, msg.row, msg.col, msg.update

  $scope.round = Round
  $scope.workspaces = Workspaces

  $scope.valid_workspaces = [ 'text', 'table', 'attachments' ]

  Workspaces.thread = Round
  Workspaces.thread_type = 'Round'

  $scope.request_round = ->
    $http.post(Routes.get_round_path channel)
      .success (round) ->
        Round.update_obj round
        for w in Round.workspaces
          Workspaces.process w

  $scope.edit_round = ->
    $scope.round.editing =
      name: round.name
      url: round.url
      priority: round.priority
      hint: round.hint
      captain: round.captain
      answer: round.answer
      wrong_answer: round.wrong_answer

  $scope.add_workspace = -> $scope.adding_workspace = true

  $scope.cancel_workspace = -> $scope.adding_workspace = false

  $scope.cancel_edit = ->
    $scope.round.editing = null

  $scope.post_edit_round = ->
    $http.post(Routes.edit_round_path($scope.round.id, {round: $scope.round.editing}))
      .success -> $scope.round.editing = null

  $scope.cancel_edit_round = (round) -> round.editing = null

  $scope.request_round()
