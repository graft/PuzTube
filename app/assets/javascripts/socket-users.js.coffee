@puztubeApp.factory 'socket', ($rootScope) ->
  socket = io.connect 'http://localhost', { port: 5000, query: 'shib=guaranteed-airline-harassment-underlying' }
  m =
    on: (event,callback,followup) ->
      socket.on(event, ->
        args = arguments
        $rootScope.$apply(-> callback.apply(socket,args))
        followup.call(socket) if followup
      )
    emit: (event,data,callback) ->
      socket.emit(event,data,->
        args = arguments
        $rootScope.$apply(-> callback.apply(socket,args)) if callback
      )
  m
