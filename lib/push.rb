require 'socket'
require 'json'

module Push
  # okay make a new
  class << self
    def socket
      TCPSocket.open 'localhost', 8000
    end

    def send(msg)
      begin
        Rails.logger.info "Sending push message #{msg}"
        socket.puts msg.to_json
      rescue Exception => e
        Rails.logger.info "Socket Push error #{e}"
      end
    end
  end
end
