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

  var currtitle;
  function blinkTitle() {
    if (currtitle) return;
    currtitle = document.title;
    document.title = "***";
    setTimeout('restoreTitle()',400);
  }

  function updateClock() {
    if ($('chatclock')) {
    }
  }

  function restoreTitle() {
    if (currtitle.match(/^\*[\w]/)) {
    document.title = currtitle;
    }
    else
    document.title = "*"+currtitle;
    currtitle = null;
  }
  function unmarkTitle() {
    if (document.title.match(/^\*[\w]/)) {
      document.title = document.title.substr(1)
    }
  }

  function scrollChat() {
    $('chatpane').scrollTop = $('chatpane').scrollHeight;
  }

  function jug_chat_update(txt) {
    if ($('chatpane')) {
      $('chatpane')
      .firstDescendant()
      .insert({ bottom: txt});
      scrollChat();
      blinkTitle();
    }
  }

  function jug_connected() {
    if ($('chatform')) $('chatform').enable();
    if ($('editables')) $('editables').removeClassName("hidden");
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

  function hideChat() {
    $('chatwindow').hide();
    $('hidechat').hide();
    $('showchat').show();
    $('mainpage').setStyle({ width: "100%" });
  }
  function showChat() {
    $('chatwindow').show();
    $('hidechat').show();
    $('showchat').hide();
    scrollChat();
    $('mainpage').setStyle({ width: "72%" });
  }
  
  function startup() {
    userlist.each(function(u) {
      subscribe_user(u,true);
    });
    update_users();
    
    $('chatwindow').setStyle({ height: (window.innerHeight-15)+'px' });
    $('chatpane').setStyle({ height: ($('chatwindow').getHeight()-170) + 'px' });
    $('chatform').disable();
    scrollChat();
    
    window.onfocus = unmarkTitle;
  }
