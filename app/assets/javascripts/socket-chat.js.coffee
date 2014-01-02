root = exports ? this

root.Socket.chat =
  join: (users) ->
    for user in users
      get_service('Chats').subscribe_user user
    apply_scope('#chat_window')

root.Socket.modules.push root.Socket.chat

root.socket.on 'chat', (msg) ->
  return if !msg.chat
  get_service('Chats').post_chat msg.chat
  update_window('chat')
  $('#chatpane').trigger 'newitem'

root.socket.on 'joined', (user) ->
  get_service('Chats').subscribe_user user
  update_window('chat')

root.socket.on 'left', (user) ->
  get_service('Chats').unsubscribe_user user
  update_window('chat')
