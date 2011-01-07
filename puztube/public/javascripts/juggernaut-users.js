  var users = {};

  function subscribe_user(user,du) {
    users[user] = true;
    if (!du) update_users();
  }

  function unsubscribe_user(user) {
    if (users[user]) delete users[user];
    update_users();
  }

  function update_users() {
    $('chatusers').firstDescendant().update();
    for (var u in users) {
      $('chatusers').firstDescendant().insert({bottom:'<li> '+u+'</li>'});
    }
  }

  function create_workspace(txt) {
    $('comments').insert({ top: txt });
  }

  function jug_chat_update(txt) {
  $('chatpane')
      .firstDescendant()
      .insert({ bottom: txt});
      $('chatpane').scrollTop = $('chatpane').scrollHeight;
  }
  
  function jug_ws_update(dv,txt) {
    $(dv).update(txt);
  }