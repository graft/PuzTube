socket = io.connect('http://localhost', { port: 80 });

socket.on('connected', function (data) {
  if ($('chatform')) $('chatform').enable();
  if ($('editables')) $('editables').removeClassName("hidden");
  socket.emit('nick',user);
  socket.emit('join',channel, function (userlist) {
  userlist.each(function(u){
    subscribe_user(u,true);
  });
  update_users();
});
});
socket.on('chat',function (msg,user) {
  if ($('chatpane')) {
    $('chatpane').firstDescendant().insert({ bottom: msg.text});
    scrollChat();
    blinkTitle();
    if (msg.user) subscribe_user(msg.user,false);
  }
});
socket.on('joined',function (user) {
  subscribe_user(user,false);
});
socket.on('left',function (user) {
  unsubscribe_user(user);
});
socket.on('new round',function (msg) {
  // request the new round
  new Ajax.Updater('roundstable', '/round/info', {
    parameters: { id: msg.round, c: 1 },
    insertion: 'bottom',
    method: 'get',
    evalScripts: true    
  });
});
socket.on('new asset', function(msg) {
  insert_asset(msg.workspace,msg.text);
});
socket.on('new workspace', function(msg) {
  new Ajax.Updater('comments', '/workspace/show', {
    parameters: { id: msg.workspace, c: 1 },
    insertion: 'bottom',
    evalScripts: true,
    method: 'get',
    onComplete: function() {
      var element = $('comments').lastChild;
      sortWorkspaces();
      if (element) {
        element.scrollTo();
        new Effect.BlindDown(element, { duration: 0.5 });
      }
    }
  });
});
socket.on('new puzzle', function(msg) {
  new Ajax.Updater(msg.table, '/puzzles/info', {
    parameters: { id: msg.puzzle, type: 'mini', c: 1 },
    insertion: 'bottom',
    method: 'get',
    evalScripts: true
  });
});

socket.on('update round', function(msg) {
  new Ajax.Updater(msg.table, '/round/info', {
    parameters: { id: msg.round },
    method: 'get'
  });
});
socket.on('update puzzle', function(msg) {
  new Ajax.Updater(msg.table, '/puzzles/info', {
    parameters: { id: msg.puzzle, type: 'mini' },
    method: 'get'
  });
});
socket.on('update puzzle info', function(msg) {
  new Ajax.Updater('info', '/puzzles/info', {
    parameters: { id: msg.puzzle, type: 'full' },
    method: 'get'
  });
});
socket.on('update workspace', function(msg) {
  new Ajax.Updater(msg.container, '/workspace/show', {
    parameters: { id: msg.workspace },
    evalScripts: true
  });
});
socket.on('update table cell', function(msg) {
  update_table_cell(msg.cell,msg.text,msg.table);
  if ($(msg.cell)) $(msg.cell).removeClassName('updating');
});
socket.on('update grid cell', function(msg) {
  update_grid_cell(msg.cell,msg.text);
  if ($(msg.cell)) $(msg.cell).removeClassName('updating');
});

socket.on('destroy puzzle', function(msg) {
  if ($(msg.puzzle)) $(msg.puzzle).remove();
});
socket.on('destroy round', function(msg) {
  if ($(msg.round)) $(msg.round).remove();
});
socket.on('destroy workspace', function(msg) {
  if ($(msg.workspace)) $(msg.workspace).remove();
});
socket.on('destroy attachment', function(msg) {
  delete_asset(msg.workspace,msg.asset);
});

users = {}

function subscribe_user(user,du) {
  if (!users[user]) {
    users[user] = true;
    if (!du) update_users();
  }
}

function unsubscribe_user(user) {
  if (users[user]) {
    delete users[user];
    update_users();
  }
}

function update_users() {
  if ($('chatusers')) {
    $('chatusers').firstDescendant().update();
    for (var u in users) {
      $('chatusers').firstDescendant().insert({bottom:'<li> '+u+'</li>'});
    }
  }
}