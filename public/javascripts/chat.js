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

function setFocus() {
  focused = false;
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

function unmarkTitle() {
  focused = true;
  if (document.title.match(/^\*[\w]/)) {
    document.title = document.title.substr(1)
  }
}

function scrollChat() {
  $('chatpane').scrollTop = $('chatpane').scrollHeight;
}
  
function startup() {
  fixchatsize();
  window.onresize = fixchatsize;
  window.onfocus = unmarkTitle;
  window.onblur = setFocus;
}

function log(txt) {
  if ("console" in window && "log" in window.console) window.console.log(txt);
}