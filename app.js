var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')

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
    console.log("Sending to channel: "+msg);
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
    console.log("Registering user "+user);
  });
  socket.on('join', function(channel,get_users){
    // adds this socket to the particular topic
    socket.join(channel);
    socket.channel = channel;
    if (socket.nick) console.log("Adding "+socket.nick+" to "+channel);
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
	  console.log(msg.command);
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
