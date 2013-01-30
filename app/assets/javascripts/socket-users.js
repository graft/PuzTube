//= require jquery_scrollTo

socket = io.connect('http://mayhem.mit.edu', { port: 5000, query: 'shib=guaranteed-airline-harassment-underlying' });

socket.on('connected', function (data) {
  if ($('#chat_input')) $('#chat_input').attr('disabled',false);
  if ($('#editables')) $('#editables').show();
  socket.emit('nick',user);
  socket.emit('join',channel, function (userlist) {
    $(userlist).each(function(i,u){
      subscribe_user(u,true);
    });
    update_users();
  });
});

socket.on('chat',function (msg,user) {
  if ($('#chatlist')) {
    $('#chatlist').append(msg.text);
    Chat.scroll();
    Chat.blink_title();
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
  $.get('/round/info', { id: msg.round, c: 1 }, function(data) {
	  $('#roundstable').append(data);
  });
});

socket.on('new asset', function(msg) {
  insert_asset(msg.workspace,msg.text);
});

socket.on('new workspace', function(msg) {
  $.get('/workspace/show', { id: msg.workspace, c: 1 },
	  function(data) {
	  	$('#comments').append(data);
      sortWorkspaces();
		  $.scrollTo($('#comments > :last-child'))
	  });
  });

socket.on('new puzzle', function(msg) {
  $.get('/puzzles/info', { id: msg.puzzle, type: 'mini', c: 1 },
    	function(data) {
	   $('#'+msg.table).append(data);
	  });
});

socket.on('update round', function(msg) {
  $('#'+msg.table).load('/round/info', { id: msg.round });
});
socket.on('update puzzle', function(msg) {
  console.log("Told to update puzzle.");
  $('#'+msg.table).load('/puzzles/info', { id: msg.puzzle, type: 'mini' });
});
socket.on('update puzzle info', function(msg) {
  $('#'+msg.puzzle).load('/puzzles/info', { id: msg.puzzle, type: 'full' });
});
socket.on('update workspace', function(msg) {
  $('#'+msg.container).load( '/workspace/show', { id: msg.workspace },
	  function() {
		  sortWorkspaces();
		  $.scrollTo($('#'+msg.container))
      if (Grid) Grid.prepare($('#'+msg.container));
	  });
});
socket.on('update table cell', function(msg) {
  update_table_cell(msg.cell,msg.text,msg.table);
  $('#'+msg.cell).removeClass('updating');
});
socket.on('update grid cell', function(msg) {
  if (grids && grids[msg.ws + '_' + msg.grid]) {
    grids[msg.ws + '_' + msg.grid].cells[msg.row][msg.col].update_txt(msg.text);
  }
});

socket.on('destroy puzzle', function(msg) {
  $('#'+msg.puzzle).remove();
});
socket.on('destroy round', function(msg) {
  $('#'+msg.round).remove();
});
socket.on('destroy workspace', function(msg) {
  $('#'+msg.workspace).remove();
});
socket.on('destroy attachment', function(msg) {
  delete_asset(msg.workspace,msg.asset);
});

users = {}

function subscribe_user(user,du) {
  if (!users[user]) {
    console.log("Adding user "+user);
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
  if ($('#chatusers')) {
    $('#chatusers > :first-child').html("");
    for (var u in users) {
      $('#chatusers > :first-child').append('<li> '+u+'</li>');
    }
  }
}
