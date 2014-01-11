@puztubeApp.factory 'Hunt', [ '$http', ->
  @puzzles = []

  @round_created = (round) => @rounds.push round
  @round_destroyed = (round) => @rounds = (r for r in @rounds when r.id != round.id)
  @round_updated = (round) => $.extend(r,round) if r.id == round.id for r in @rounds

  @puzzle_created = (puzzle) =>
    @puzzles.push puzzle
    round.puzzles.push puzzle for round in @rounds when round.id == puzzle.round_id
  @puzzle_destroyed = (puzzle) =>
    @puzzles = (p for p in @puzzles when p.id != puzzle.id)
    for round in @rounds
      if round.id == puzzle.round_id
        round.puzzles = (p for p in round.puzzles when p.id != puzzle.id)
        break

  @puzzle_updated = (puzzle) =>
    $.extend(p,puzzle) for p in @puzzles when p.id == puzzle.id
    for round in @rounds
      if round.id == puzzle.round_id
        $.extend(p,puzzle) for p in round.puzzles when p.id == puzzle.id
        break

  @update_obj = (hunt) =>
    $.extend @, hunt
    @puzzles = []
    for round in @rounds
      for puzzle in round.puzzles
        puzzle.round = round.name
        @puzzles.push puzzle

  @
]

@puztubeApp.controller "huntController", ($scope, $http, Hunt, socket) ->
  socket.on 'connected', (msg) ->
    $scope.visible = true
    socket.emit 'join', channel

  socket.on 'new round', (msg) -> 
    console.log "Got new round!"
    Hunt.round_created msg.round
  socket.on 'update round', (msg) ->
    console.log "Updating round"
    Hunt.round_updated msg.round
  socket.on 'destroy round', (msg) ->
    console.log "Destroying round"
    Hunt.round_destroyed msg.round

  socket.on 'new puzzle', (msg) -> 
    console.log "Got new puzzle!"
    Hunt.puzzle_created msg.puzzle
  socket.on 'update puzzle', (msg) ->
    console.log "Updating puzzle"
    console.log msg
    Hunt.puzzle_updated msg.puzzle
  socket.on 'destroy puzzle', (msg) ->
    console.log "Destroying puzzle"
    console.log msg
    Hunt.puzzle_destroyed msg.puzzle

  $scope.hunt = Hunt

  $scope.grouped = true

  $scope.user = user

  $scope.request_hunt = ->
    $http.post(Routes.get_hunt_path({ channel: channel }))
      .success (hunt) -> Hunt.update_obj hunt

  $scope.create_round = ->
    $scope.new_round =
      name: "Round Name"
      url: "Round URL"
      hunt_id: Hunt.id

  $scope.round_path = (round) -> Routes.show_round_path(round.id)

  $scope.edit_round = (round) -> 
    round.editing =
      name: round.name
      url: round.url
      priority: round.priority
      hint: round.hint
      captain: round.captain
      answer: round.answer

  $scope.post_edit_round = (round) ->
    $http.post(Routes.edit_round_path(round.id, { round: round.editing }))
      .success -> round.editing = null

  $scope.cancel_edit_round = (round) -> round.editing = null

  $scope.destroy_round = (round) ->
    return unless confirm "Are you sure?"
    $http.post(Routes.destroy_round_path({ id: round.id }))

  $scope.post_new_round = ->
    console.log "Posting round"
    $http.post(Routes.create_round_path({ round: $scope.new_round }))
      .success -> $scope.new_round = null
    
  $scope.cancel_new_round = -> $scope.new_round = null

  $scope.puzzle_row = (puzzle) ->
    if puzzle.editing then 'puzzle_row_edit' else 'puzzle_row'

  $scope.puzzle_path = (puzzle) -> Routes.show_puzzle_path(puzzle.id)

  $scope.create_puzzle = (round) ->
    round.new_puzzle =
      name: "Puzzle Name"
      url: "Puzzle URL"
      round_id: round.id

  $scope.edit_puzzle = (puzzle) ->
    puzzle.editing =
      name: puzzle.name
      url: puzzle.url
      priority: puzzle.priority
      status: puzzle.status
      hint: puzzle.hint
      captain: puzzle.captain
      answer: puzzle.answer

  $scope.cancel_new_puzzle = (round) -> round.new_puzzle = null
  $scope.post_new_puzzle = (round) ->
    console.log "Posting puzzle"
    $http.post(Routes.create_puzzle_path({ puzzle: round.new_puzzle }))
      .success -> round.new_puzzle = null

  $scope.post_edit_puzzle = (puzzle) ->
    $http.post(Routes.edit_puzzle_path(puzzle.id, { puzzle: puzzle.editing }))
      .success -> puzzle.editing = null

  $scope.cancel_edit_puzzle = (puzzle) -> puzzle.editing = null
  $scope.destroy_puzzle = (puzzle) ->
    return unless confirm "Are you sure?"
    $http.post(Routes.destroy_puzzle_path({ id: puzzle.id }))


  $scope.request_hunt()

  $scope.canvas = (puzzle) -> 'act-'+puzzle.id

  $scope.draw_activity = (puzzle, activities) ->
    (activities) ->
      puzzle.activities = activities
      mx = new Date()
      mn = new Date(puzzle.created_at)
      num = 40
      act_bins = (0 for n in [0..num])
      for act in activities
        time = new Date(act.created_at)
        bin = parseInt num*(Math.max(0,time-mn) / (mx-mn+1))
        act_bins[bin]++
      canvas = $('#'+$scope.canvas(puzzle))[0]
      context = canvas.getContext("2d")
      context.clearRect(0,0,canvas.width,canvas.height)
      line = new RGraph.Line($scope.canvas(puzzle),act_bins)
      line.Set('chart.gutter.left', 30)
      line.Set('chart.gutter.top', 5)
      line.Set('chart.gutter.right', 0)
      line.Set('chart.gutter.bottom', 0)
      line.Set('chart.text.size',8)
      line.Set('chart.background.barcolor1','#020')
      line.Set('chart.background.barcolor2','#020')
      line.Set('chart.background.grid',false)
      line.Set('chart.ylabels.count',1)
      line.Set('chart.noaxes',true)
      line.Set('chart.title',$scope.time_format((mx-mn)/1000))
      line.Set('chart.title.color',"#f00")
      line.Set('chart.title.vpos',2.2)
      line.Set('chart.title.hpos',0.35)
      line.Set('chart.title.bold',false)
      line.Set('chart.title.size',8)
      line.Set('chart.text.color', '#f00')
      line.Set('chart.colors', ['#0f0'])
      line.Set('chart.linewidth', 2)
      line.Draw()

  $scope.refresh_activities = (round) ->
    for puzzle in round.puzzles
      $http.post(Routes.puzzle_activities_path({ id: puzzle.id }))
        .success $scope.draw_activity(puzzle)
