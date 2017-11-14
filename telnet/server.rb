require 'socket'
require_relative './client'

module Telnet
  class Server
    def initialize(port)
      @tcp_server = TCPServer.new(port)
      @clients = []
    end

    def serve(app_class)
      puts "Starting server on port #{@tcp_server.local_address.ip_port}"
      puts "Serving app: #{app_class}"

      loop do
        Thread.start(@tcp_server.accept) do |socket|

          # socket = @tcp_server.accept
          client = Client.new(socket: socket, app: app_class.new(socket))

          @clients << client

          puts "Client #{client} connected"
          puts "#{@clients.size } clients connected"

          client.serve

          @clients.delete(client)
          puts "disconnected"
        end
      end
    end

    def stop
      @clients.each do |client|
        client.hangup
      end
    end
  end
end
