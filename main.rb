require './app/chat'
require './telnet/server'

server = Telnet::Server.new(4040)
trap("SIGINT") do
  server.stop
  exit
end

server.serve(App::Chat)
