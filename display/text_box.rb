require_relative './box'
require 'word_wrap'
require 'word_wrap/core_ext'

module Display
  class TextBox < Box
    def add_text(text)
      @text ||= ""
      @text << text
    end

    def draw
      super

      wrapped = @text.wrap(width - 2)
      wrapped.split("\n").each.with_index(1) do |line, index|
        if index == height - 2
          more = "[ more ]"
          at(left + width - "[ more ]".size - 1, top + index, more)
          break
        end
        at(left + 1, top + index, line)
      end
    end
  end
end
