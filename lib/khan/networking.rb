module Khan
  module Networking
    require 'socket'

    START_PORT = 3000

    def self.port_available?(port)
      socket = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
      sockaddr = Socket.sockaddr_in(port, '0.0.0.0')
      begin
        socket.bind(sockaddr)
        return true
      rescue Exception
        return false
      ensure
        socket.close
      end
    end

    def self.get_available_port
      port = START_PORT
      until port_available?(port)
        port += 1
      end
      port
    end
  end
end