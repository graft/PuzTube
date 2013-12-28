@puztubeApp.factory 'Chats', [ '$http', ->
  @list = []
  @users = {}
  @add_chat = (chat) =>
    @list.push chat
  @concat_chats = (chats) =>
    @add_chat chat for chat in chats
  @subscribe_user = (user) =>
    @users[user] = true
  @unsubscribe_user = (user) =>
    delete @users[user] if @users[user]
  @
]

@puztubeApp.controller "chatController", ($scope, $http, Chats) ->
  $scope.Chats = Chats

  $scope.dateFormat = (chat) ->
    date = new Date(chat.created_at)
    (date.getMonth()+1) + '/' + date.getDate()
  $scope.timeFormat = (chat) ->
    date = new Date(chat.created_at)
    date.getHours() + ':' + date.getMinutes()
  $scope.blink_title = ->
    return if $scope.cache_title
    $scope.cache_title = document.title
    document.title = "***"
    setTimeout($scope.restore_title,400)

  $scope.restore_title = ->
    if $scope.cache_title.match(/^\*[\w]/) || $scope.focused
      document.title = $scope.cache_title
    else
      document.title = "*" + $scope.cache_title
    $scope.cache_title = null

  $scope.unmark_title = ->
    $scope.focused = true
    document.title = document.title.substr(1) if document.title.match(/^\*[\w]/)

  $scope.unset_focus = -> focused = false

  $scope.post_chat = ->
    $http.post(Routes.thread_chat_path({ thread: thread, channel: channel, chat_input: $scope.chat_text }))
    $scope.chat_text = ""

  $scope.request_chats = ->
    $http.post(Routes.recent_chats_path({ channel: channel }))
      .success (chats) -> Chats.concat_chats chats
      
  $scope.request_chats()
