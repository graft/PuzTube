var Chat = {
  hidden: false,
  cache_title: null,
  focused: true,
  hide: function() {
    Chat.link.html('show chat');
    Chat.window.hide();
    Chat.page.css( 'width', '100%' );
  },
  show: function() {
    Chat.link.html('hide chat');
    Chat.window.show();
    Chat.page.css( 'width', '72%' );
    Chat.scroll();
  },
  toggle: function() {
    if (Chat.hidden)
     Chat.show();
    else
     Chat.hide();
    Chat.hidden = !Chat.hidden;
  },
  scroll: function() {
    Chat.pane.scrollTop(Chat.pane.prop('scrollHeight'));
  },
  fixsize: function() {
    Chat.window.css('height', ($(window).innerHeight() - 15) + 'px' );
    Chat.pane.css('height', (Chat.window.height()-170) + 'px');
    Chat.scroll();
  },
  blink_title: function() {
    if (Chat.cache_title) return;
    Chat.cache_title = document.title;
    document.title = "***";
    setTimeout(Chat.restore_title,400);
  },
  restore_title: function() {
    if (Chat.cache_title.match(/^\*[\w]/) || Chat.focused)
      document.title = Chat.cache_title;
    else
      document.title = "*" + Chat.cache_title;
    Chat.cache_title = null;
  },
  unmark_title: function() {
    Chat.focused = true;
    if (document.title.match(/^\*[\w]/)) {
      document.title = document.title.substr(1)
    }
  },
  unset_focus: function() {
    focused = false;
  },
  clear_input: function() {
    Chat.input.val('');
  },
  startup: function() {
    console.log("Starting chat.");
    Chat.box = $('#togglechat');
    Chat.link = $('#togglechat a');
    Chat.window = $('#chatwindow');
    Chat.pane = $('#chatpane');
    Chat.page = $('#mainpage');
    Chat.form = $('#chatform');
    Chat.input = $('#chat_input');
    Chat.fixsize();
    Chat.link.click(Chat.toggle);
    $(window).resize(Chat.fixsize);
    $(window).focus(Chat.unmark_title);
    $(window).blur(Chat.unset_focus);
    Chat.form.on('ajax:beforeSend', Chat.clear_input);
  }
};

$(Chat.startup);
