@puztubeApp.factory 'Puzzle', [ '$http', ->
  @update_obj = (puzzle) =>
    $.extend @, puzzle

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

@puztubeApp.controller "puzzleController", ($scope, $http, Puzzle, Workspaces, socket) ->
  socket.on 'connected', (msg) ->
    $scope.visible = true

  socket.on 'update puzzle', (msg) ->
    console.log "Updating puzzle"
    Puzzle.update_obj msg.puzzle

  socket.on 'new workspace', (msg) ->
    console.log "Adding workspace"
    Workspaces.process msg.workspace
    Puzzle.add_workspace msg.workspace

  socket.on 'update workspace', (msg) ->
    console.log "Updating workspace"
    Workspaces.process msg.workspace
    Puzzle.update_workspace msg.workspace

  socket.on 'update cell', (msg) ->
    console.log "Updating workspace cell"
    console.log msg
    Puzzle.update_workspace_cell msg.workspace, msg.row, msg.col, msg.update

  $scope.puzzle = Puzzle
  $scope.workspaces = Workspaces

  $scope.valid_workspaces = [ 'text', 'table', 'attachments' ]

  Workspaces.thread = Puzzle
  Workspaces.thread_type = 'Puzzle'

  $scope.request_puzzle = ->
    $http.post(Routes.get_puzzle_path channel)
      .success (puzzle) ->
        Puzzle.update_obj puzzle
        for w in Puzzle.workspaces
          Workspaces.process w

  $scope.edit_puzzle = ->
    $scope.puzzle.editing =
      name: puzzle.name
      url: puzzle.url
      priority: puzzle.priority
      status: puzzle.status
      hint: puzzle.hint
      captain: puzzle.captain
      answer: puzzle.answer
      wrong_answer: puzzle.wrong_answer

  $scope.add_workspace = -> $scope.adding_workspace = true

  $scope.cancel_workspace = -> $scope.adding_workspace = false

  $scope.cancel_edit = ->
    $scope.puzzle.editing = null

  $scope.post_edit_puzzle = ->
    $http.post(Routes.edit_puzzle_path($scope.puzzle.id, {puzzle: $scope.puzzle.editing}))
      .success -> $scope.puzzle.editing = null

  $scope.cancel_edit_puzzle = (puzzle) -> puzzle.editing = null

  $scope.request_puzzle()
