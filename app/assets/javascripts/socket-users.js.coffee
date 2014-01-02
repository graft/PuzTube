root = exports ? this

root.socket = io.connect 'http://localhost', { port: 5000, query: 'shib=guaranteed-airline-harassment-underlying' }

root.Socket = {}

root.Socket.modules = []

root.Socket.join = (users) ->
  for module in root.Socket.modules
    module.join(users) if module.join

root.socket.on 'connected', (data) ->
  console.log "Joined channel"
  root.socket.emit 'nick', user
  root.socket.emit 'join', channel, root.Socket.join
