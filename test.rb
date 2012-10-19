require 'SocketIO'

def init
  $socket ||= SocketIO.connect("localhost", sync: true) do
    before_start do
      on_message do |m|
        puts "incoming message: #{m}"
      end
      on_event('news') do |d|
        puts d.first
      end
      on_event('control-ack') do |d|
        puts d.first
      end
    end
  end
end

init
puts "release control!"

def send(event,msg)
  begin 
    $socket.emit(event,msg)
  rescue Exception => e
    puts "This was the error: #{e}"
    # try again:
    $socket = nil
    init
    $socket.emit(event,msg)
  end
end

loop do
  sleep 1
  send('control', {:goodbye => "moon"})
end
