#!/usr/bin/env ruby

# file: all_todo.rb


require 'polyrex-headings'


class AllTodo

  def initialize(s)

    declaration = '<?ph schema="sections[title]/section[x]"?>'
    @px = PolyrexHeadings.new(declaration + "\n" + s).to_polyrex

  end

  def to_px
    @px
  end
end
