require './display/box'

module App
  class InputBox < Display::Box
    IGNORED = ["\r"]

    attr_reader :content

    def initialize(*)
      super
      @content = ""
    end

    def top
      parent.height - height
    end

    def left
      0
    end

    def width
      parent.width
    end

    def height
      3
    end

    def draw
      super
      at(3, 2, "> #{@content}", relative: true)
    end

    def input(char)
      return if IGNORED.include?(char)

      if char  == "\x7F" #backspace
        @content = @content[0..@content.size - 2]
      else
        @content << char
      end
      at(5, 2, "#{@content}".ljust(width - 5), relative: true)
    end

    def clear
      @content = ""
      at(5, 2, " " * (width - 5), relative: true)
    end
  end
end
