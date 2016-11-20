#!/usr/bin/env ruby

# file: all_todo.rb


require 'polyrex-headings'


class AllTodo

  def initialize(s)

    # remove the file heading     
    lines = s.lines
    lines.shift 3
    
    declaration = '<?ph schema="sections[title]/section[x]"?>'
    @px = PolyrexHeadings.new(declaration + "\n" + lines.join).to_polyrex

  end

  def to_px
    @px
  end
end