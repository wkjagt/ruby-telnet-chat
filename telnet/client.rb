require 'socket'
require 'thread'
require_relative './iac'

module Telnet
  class Client
    ConnectionClosed = Class.new(StandardError)

    def initialize(socket:, app:)
      @socket = socket
      @app = app
      @iac = IAC.new(@socket)
    end

    def serve
      @app.render

      @iac.request_window_size
      @iac.dont_linemode

      loop do
        next unless char_or_command = next_char_or_command
        # next if flush_arrow_key(char_or_command)

        case char_or_command
        when IAC::WindowSize
          @app.resize(char_or_command.to_h)
        when "\x03" # ctrl c
          hangup
          break
        when :noop
        else
          @app.input_char(char_or_command)
        end
      end
    rescue ConnectionClosed
      nil
    end

    def hangup
      @app.close
      @socket.close
    end

    private

    def read_nav_key(char)
      return false unless char == "\e"

      while char = @socket.recv_nonblock(1)
        case char
        when "A" then return :up
        when "B" then return :down
        when "C" then return :right
        when "D" then return :left
        end
      end
    rescue
      :esc
    end

    def next_char_or_command
      return unless char = @socket.recv_nonblock(1)
      nav_key = read_nav_key(char)
      return nav_key if nav_key

      raise(ConnectionClosed) if char == ""

      @iac.command?(char) ? @iac.next_command : char
    rescue IO::EAGAINWaitReadable
      nil
    end
  end
end
