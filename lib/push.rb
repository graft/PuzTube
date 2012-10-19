require 'SocketIO'
require 'json'

module Push
  # okay make a new
  class << self
    def socket
      @socket ||= SocketIO.connect("localhost",sync: true) do
        Rails.logger.info "Starting new socket."
        before_start do
          on_message do |m|
            puts "incoming message: #{m}"
          end
          on_event('news') do |d|
            Rails.logger.info d.first
          end
        end
      end
    end

    def send(msg)
      begin
        Rails.logger.info "Sending push message #{msg}"
        socket.emit('control', msg.to_json)
      rescue Exception => e
        Rails.logger.info "Socket Push error #{e}"
        # try again.
        @socket = nil
        socket.emit('control',msg)
      end
    end
  end
end
