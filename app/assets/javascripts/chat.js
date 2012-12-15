function hideChat() {
  $('#chatwindow').hide();
  $('#hidechat').hide();
  $('#showchat').show();
  $('#mainpage').css( 'width', "100%" );
}
function showChat() {
  $('#chatwindow').show();
  $('#hidechat').show();
  $('#showchat').hide();
  $('#mainpage').css('width', "72%" );
  scrollChat();
}
function fixchatsize() {
  $('#chatwindow').css('height', ($(window).innerHeight()-15)+'px' );
  $('#chatpane').css('height', ($('#chatwindow').height()-170) + 'px');
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
    if ($('#chatclock')) {
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
  $('#chatpane').scrollTop($('#chatpane').prop('scrollHeight'));
}

function chat_startup() {
  console.log("Starting up.");
  fixchatsize();
  $('#showchat').hide();
  $(function($) {
  	$('#chatform').bind('ajax:beforeSend', function() {
	  	console.log("This might work.");
	  	$('#chat_input').val('');
  	});
  });
  $(window).resize(fixchatsize);
  $(window).focus(unmarkTitle);
  $(window).blur(setFocus);
}

function log(txt) {
  if ("console" in window && "log" in window.console) window.console.log(txt);
}
