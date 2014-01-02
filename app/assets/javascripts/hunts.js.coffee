#= require socket-hunt

@puztubeApp.factory 'Hunt', [ '$http', ->
  @rounds = []
  @puzzles = []

  @set_rounds = (rounds) =>
    @rounds = rounds
    @puzzles = []
    for round in rounds
      for puzzle in round.puzzles
        puzzle.round = round.name
        @puzzles.push puzzle

  @
]

@puztubeApp.controller "huntController", ($scope, $http, Hunt) ->
  $scope.hunt = Hunt

  $scope.grouped = true

  $scope.request_rounds = ->
    $http.post(Routes.rounds_list_path({ hunt: channel }))
      .success (rounds) -> Hunt.set_rounds rounds

  $scope.edit_puzzle = (puzzle) ->
    puzzle.editing = true
  $scope.cancel_edit = (puzzle) ->
    puzzle.editing = false
  $scope.puzzle_row = (puzzle) ->
    if puzzle.editing then 'puzzle_row_edit' else 'puzzle_row'
      
  $scope.request_rounds()

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
