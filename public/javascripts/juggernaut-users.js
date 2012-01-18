  var users = {};
  var channel;
  var user;

  function log(txt) {
  if ("console" in window && "log" in window.console) window.console.log(txt);
  }

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
  var focused = true;
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
    if (currtitle.match(/^\*[\w]/) || focused) {
    document.title = currtitle;
    }
    else
    document.title = "*"+currtitle;
    currtitle = null;
  }
  function setFocus() {
    focused = false;
  }
  function unmarkTitle() {
    focused = true;
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
    //testTimer = setTimeout('testConnection()',40000+Math.random()*30000);
  }

  var connectiontimer;
  var testTimer;
  var activetime;

  // okay, so, you test the connection. If it is active, it sets a timeout to
  // test the connection, and a timeout to reconnect. 

  function connectionActive(newusers) {
    // don't worry about clearing connectiontimer, just set the active time
    activetime = (new Date()).getTime();
    //window.console.log("Connection active. active time is "+activetime);
    new Effect.Highlight('connectiontest', { startcolor: '#99cc33', endcolor: '#1d5875', restorecolor: '#1d5875' });
    // test the connection every 60 seconds to be safe
    if (null) {
      users = {};
      newusers.each(function(o) { users[o] = true; });
      update_users();
    }
  
    if (!testTimer) {
    }
  }

  // this gets set by rails when you test the connection, so if juggernaut
  // doesn't approve you, you will timeout and reconnect.
  function connectionTimer() {
  log("Setting reconnect timer.");
    if (!connectiontimer) connectiontimer = setTimeout('reconnectJug()',5000);
  }

  function testConnection() {
    log("Testing the connection...");
    new Ajax.Request('/welcome/test?channel='+channel+'&amp;user='+user, {method:'get', asynchronous:true, evalScripts:true});
    // ensure you don't test twice... you might have been clicked by hand.
    if (testTimer) clearTimeout(testTimer);
    // set the test timer here rather than elsewhere to ensure you always keep testing.
    log("Setting testTimer.");
    //testTimer = setTimeout('testConnection()',360000+Math.random()*60000);
  }

  function reconnectJug() {
    var currenttime = (new Date()).getTime();
    connectiontimer = null;
    // you were active in the last ten seconds.
    if ((activetime+10000) > currenttime) return;
    log("Reconnecting juggernaut.");
    jug_swf.disconnect();
    jug_swf.reconnect();
    new Effect.Highlight('connectiontest', { startcolor: '#cc3333', endcolor: '#1d5875', restorecolor: '#1d5875' });
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

  function fixchatsize() {
    $('chatwindow').setStyle({ height: (window.innerHeight-15)+'px' });
    $('chatpane').setStyle({ height: ($('chatwindow').getHeight()-170) + 'px' });
    scrollChat();
  }
  
  function startup() {
    userlist.each(function(u) {
      subscribe_user(u,true);
    });
    update_users();
    
    fixchatsize();
    $('chatform').disable();

    window.onresize = fixchatsize;
    window.onfocus = unmarkTitle;
    window.onblur = setFocus;
  }
