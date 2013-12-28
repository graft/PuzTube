
socket = io.connect 'http://localhost', { port: 5000, query: 'shib=guaranteed-airline-harassment-underlying' }

socket.on 'connected', (data) ->
  $('#chat_input').attr('disabled',false) if $('#chat_input')
  $('#editables').show() if ($('#editables'))
  socket.emit 'nick', user
  socket.emit 'join', channel, (users) ->
    for user in users
      getSrv('Chats').subscribe_user user, true
    applyScope('#chatwindow')

socket.on 'chat', (msg) ->
  return if !msg.chat
  getSrv('Chats').add_chat msg.chat
  getSrv('Chats').subscribe_user msg.chat.user
  applyScope('#chatwindow')
  $('#chatpane').trigger 'newitem'

socket.on 'joined', (user) ->
  getSrv('Chats').subscribe_user user
  applyScope('#chatwindow')

socket.on 'left', (user) ->
  getSrv('Chats').unsubscribe_user user
  applyScope('#chatwindow')
