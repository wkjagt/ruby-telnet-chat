require './display/box'
require 'ansi'

module App
  class HistoryBox < Display::Box
    def initialize(*)
      super
      @messages = []
    end

    def top
      0
    end

    def left
      0
    end

    def width
      parent.width
    end

    def height
      parent.height - 3
    end

    def draw
      super
      draw_messages
    end

    def add_message(message)
      @messages << message
      draw
      output
    end

    def draw_messages
      @messages.last(height - 2).reverse.map.with_index do |message, index|
        user_formatted = ANSI.green { message["user"] || "?" }
        message = message["content"]

        formatted = "#{user_formatted} : #{message}".ljust(width - 5)
        at(3, height - 1 - index, formatted, relative: true)
      end.join
    end
  end
end
