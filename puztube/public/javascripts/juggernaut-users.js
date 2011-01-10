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
    if ($('chatusers')) {
    $('chatusers').firstDescendant().update();
    for (var u in users) {
      $('chatusers').firstDescendant().insert({bottom:'<li> '+u+'</li>'});
    }
    }
  }

  function create_workspace(txt) {
    $('comments').insert({ top: txt });
  }

  function jug_chat_update(txt) {
    if ($('chatpane')) {
      $('chatpane')
      .firstDescendant()
      .insert({ bottom: txt});
      $('chatpane').scrollTop = $('chatpane').scrollHeight;
    }
  }
  
  function jug_ws_update(dv,txt) {
    $(dv).update(txt);
  }
  
  function startup() {
    userlist.each(function(u) {
    subscribe_user(u,true);
    });
    update_users();
    new Draggable('chatwindow',{handle: 'chattitle'});
    new Resizeable('chatwindow',{
      resize:function(el) {
        hgt = $('chatwindow').getHeight() - $('chatusers').getHeight() - $('chatbox').getHeight() - 50;
        $('chatpane').style.height = hgt+'px';
        hgt += 30;        $('chatbox').style.top = hgt+'px';
        hgt += 30;        $('chatusers').style.top = hgt+'px';
      }
    });
    $('chatform').disable();
//     $(document).observe('juggernaut:disconnected', function(){ alert('Why have you forsaken me!') }); 
//     $(document).observe('juggernaut:initialized', function(){ alert('Initialized.') }); 
//     $(document).observe('juggernaut:reconnect', function(){ alert('Reconnect.') }); 
//     $(document).observe('juggernaut:connect', function(){ alert('Trying to connect.') }); 
//     $(document).observe('juggernaut:connected', function(){ alert('Connected.') }); 
  }