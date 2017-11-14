module Display
  class Window
    attr_reader :width, :height, :left, :top

    def initialize(size)
      resize(size)
      @left, @top = 0, 0
      @output = ""
    end

    def output
      children_output
    end

    def children_output
      out = ""
      children.each do |child|
        child.draw
        out << child.output
      end
      out
    end

    def register(child)
      children << child
    end

    def resize(width:, height:)
      @output = ""
      @width, @height = width, height
      children.each(&:draw)
    end

    def children
      @children ||= []
    end
  end
end
