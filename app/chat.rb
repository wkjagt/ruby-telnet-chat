require './display/window'
require './app/pub_sub'
require './app/history_box'
require './app/input_box'

module App
  class Chat
    CLEAR_SCREEN = "\e[2J"
    ENTER_KEY = "\x00"
    IGNORED = [:up, :down, :left, :right, :esc]

    def initialize(output)
      @window = Display::Window.new(width: 80, height: 24)
      @history_box = HistoryBox.new(parent: @window)
      @input_box = InputBox.new(parent: @window)
      @output = output

      @pubsub = PubSub.new
      @pubsub.listen do |message|
        @output.write(@history_box.add_message(message))
      end

      @user = nil
    end

    def render
      @output.write(CLEAR_SCREEN)
      @output.write(@window.output)
    end

    def input_char(char)
      return if IGNORED.include?(char)

      case char
      when ENTER_KEY
        if @input_box.content.start_with?("/")
          handle_command(@input_box.content)
        else
          @pubsub.publish(user: @user, content: @input_box.content)
          @output.write(@input_box.clear)
        end
      else
        @output.write(@input_box.input(char))
      end
    end

    def resize(size)
      @window.resize(size)
      render
    end

    def handle_command(content)
      params = content[1..-1].split(" ")
      command = params.shift

      case command
      when "iam"
        new_name = params.join(" ")
        @pubsub.publish(user: @user, content: "<< Changed name to #{new_name} >>")
        @user = new_name
        @output.write(@input_box.clear)
      else
        # bell
      end
    end

    def close
      @output.write(CLEAR_SCREEN)
      @output.write("Bye\n\r")
    end
  end
end
