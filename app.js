var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')

io.configure(function (){
  io.set('authorization', function (handshakeData, callback) {
    // findDatabyip is an async example function
    io.log.info("auth request from "+handshakeData.address.address);
      if (handshakeData.query.shib == 'guaranteed-airline-harassment-underlying'
	      || handshakeData.address.address == '127.0.0.1') {
        callback(null, true);
      } else {
        callback(null, false);
      }
  })
});

app.listen(5000);

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }

    res.writeHead(200);
    res.end(data);
  });
}

var users = {};

var commands = {
  'to_channel': function (msg) {
    io.log.info("Sending to channel: "+msg);
    io.sockets.in(msg.channel).emit(msg.command, msg);
  },
  'to_user': function (msg) {
    users[msg.private].emit(msg.command, msg);
  },
  'to_all': function (msg) {
    io.sockets.emit(msg.command,msg);
  }
};

io.sockets.on('connection', function (socket) {
  socket.emit('connected', { hello: 'world' });
  socket.on('nick', function (user) {
    users[user] = socket;
    socket.nick = user;
    io.log.info("Registering user "+user);
  });
  socket.on('join', function(channel,get_users){
    // adds this socket to the particular topic
    socket.join(channel);
    socket.channel = channel;
    if (socket.nick) io.log.info("Adding "+socket.nick+" to "+channel);
    // list current users
    var clients = io.sockets.clients(channel);
    var userlist = []
    clients.forEach(function(c) {
      if (c.nick) userlist.push(c.nick);
    });
    get_users(userlist);
    if (socket.nick) socket.broadcast.to(channel).emit('joined',socket.nick);
  });
  socket.on('control',function (msg) {
    // unfortunately, the control cannot speak properly
    msg = JSON.parse(msg);
    socket.nick = "control";
	  io.log.debug(msg.command);
	  socket.emit('control-ack', { moon: "went bye" });
    if (msg.channel)
      commands["to_channel"](msg);
    else if (msg.private)
      commands["to_user"](msg);
    else
      commands["to_all"](msg);
  });
  socket.on('disconnect', function () {
    if (socket.channel && socket.nick) io.sockets.in(socket.channel).emit('left', socket.nick);
  });
});
