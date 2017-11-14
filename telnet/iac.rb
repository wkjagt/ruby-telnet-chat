module Telnet
  class IAC
    WindowSize = Struct.new(:width, :height)

    TRANSMIT_BINARY = 0
    ECHO = 1
    SUPPRESS_GO_AHEAD = 3
    NAWS = 31
    LINEMODE = 34
    SB = 250
    WILL = 251
    WONT = 252
    DO = 253
    DONT = 254
    IAC = 255

    def initialize(socket)
      @socket = socket
    end

    def command?(char)
      received = unpack([char])
      received == [IAC]
    end

    def request_window_size
      send([DO, NAWS])
    end

    def request_transmit_binary
      send([DO, TRANSMIT_BINARY])
    end

    def dont_linemode
      send([WILL, ECHO])
      send([WILL, SUPPRESS_GO_AHEAD])
    end

    def unpack(chars)
      chars.map { |char| char.unpack('H*').first.to_i(16) }
    end

    def next_command
      case receive(size: 2)
      when [WILL, NAWS]
        :noop
      when [SB, NAWS]
        # data incoming
        window_size_from_sb(receive(size: 6))
      when [DO, ECHO], [DO, SUPPRESS_GO_AHEAD]
        # nice
      else
        nil
      end
    end

    def window_size_from_sb(sb)
      _, width, _, height, _, _ = sb
      WindowSize.new(width, height)
    end

    def receive(size:)
      data = []
      size.times { data << @socket.recv_nonblock(1) }
      unpack(data)
    end

    def send(options)
      data = [IAC] + options
      @socket.write(data.pack('C*'))
    end
  end
end
