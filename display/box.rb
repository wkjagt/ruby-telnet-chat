require 'tty-cursor'

module Display
  class Box < Window
    attr_reader :output, :parent

    def initialize(parent:)
      parent.register(self)

      @parent = parent
      @output = ""
    end

    def draw
      @output = ""

      draw_top_line
      draw_sides
      draw_bottom_line

      children.each do |child|
        child.draw
        @output << child.output
      end
    end

    private

    def draw_sides
      1.upto(height - 2) do |y|
        at(left, y + top, "┃")
        at(left + width - 1, y + top, "┃")
      end
    end

    def draw_top_line
      at(left, top, "┏" + "━" * (width - 2) + "┓")
    end

    def draw_bottom_line
      at(left, top + height - 1, "┗" + "━" * (width - 2) + "┛")
    end

    def at(x, y, string, relative: false)
      return at(x + left - 1, y + top - 1, string) if relative
      output << TTY::Cursor.move_to(x, y) + string
    end
  end
end
