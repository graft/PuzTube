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

  function jug_chat_update(txt) {
    if ($('chatpane')) {
      $('chatpane')
      .firstDescendant()
      .insert({ bottom: txt});
      $('chatpane').scrollTop = $('chatpane').scrollHeight;
    }
  }
  
  function startup() {
    userlist.each(function(u) {
    subscribe_user(u,true);
    });
    update_users();
    new Draggable('chatwindow',{handle: 'chattitle'});
    new Resizeable('chatwindow',{
      minHeight: '100',
      //minWidth: '250',
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

  var connectiontimer;
  var testTimer;
  var activetime;

  function connectionActive(channel,user) {
    // don't worry about clearing connectiontimer, just set the active time
    activetime = (new Date()).getTime();
    //window.console.log("Connection active. active time is "+activetime);
    new Effect.Highlight('connectiontest', { startcolor: '#99cc33', endcolor: '#1d5875', restorecolor: '#1d5875' });
    // test the connection every 25 seconds to be safe
    if (!testTimer) testTimer = setTimeout('testConnection(\''+channel+'\',\''+user+'\')',60000)
  }

  function testConnection(channel,user) {
    new Ajax.Request('/welcome/test?channel='+channel+'&amp;user='+user, {asynchronous:true, evalScripts:true});
    testTimer = null;
  }

  function reconnectJug() {
    var currenttime = (new Date()).getTime();
    //window.console.log("Reconnecting. currenttime is "+currenttime, " activetime is "+activetime);
    if ((activetime+10000) > currenttime) {
      connectiontimer = null;
      return;
    }
    jug_swf.disconnect();
    jug_swf.reconnect();
    connectiontimer = null;
    new Effect.Highlight('connectiontest', { startcolor: '#cc3333', endcolor: '#1d5875', restorecolor: '#1d5875' });
  }

  function connectionTimer() {
    if (!connectiontimer) {
    	connectiontimer = setTimeout('reconnectJug()',5000);
    }
  }
