#!/usr/bin/env ruby

# file: all_todo.rb


require 'pxrowx'
require 'polyrex-headings'


class AllTodo

  def initialize(s)

    # remove the file heading     
    lines = s.lines
    lines.shift 3
    
    @fields = %w(todo when duration priority)
    declar = "<?ph schema='sections[title]/section[#{@fields.join(',')}]'" + 
        " format_masks[0]='[!todo]'?>"

    @px = PolyrexHeadings.new(declar + "\n" + lines.join).to_polyrex


  end
  
  def detail()
    
    doc = Rexle.new(@px.to_xml)
    a = scan doc.root.element('records')
    lines = scan_print a
    
    filename = 'all_todo_detail.txt'
    heading = [filename, '=' * filename.length, '', ''].join("\n")
    
    heading + lines.join("\n")    
    
  end
  
  alias breakdown detail
  
  def parse_detail(s)
    
    lines = s.lines
    lines.shift 3
    pr = PxRowX.new(lines.join)
    pr.to_xml pretty: true    

  end

  def to_px
    @px
  end
  
  private
  
  
  def scan(node)

    node.elements.map do |section|

      summary = section.xpath('summary').map do |x|
        @fields.map {|y| x.text(y)}
      end

      summary + scan(section.element('records'))
    end
  end

  def scan_print(a, indent=0)

    lines = []

    a.each do |row_children|

      row = row_children.shift
      
      @fields.zip(row).each do |col|

        label, value = col
        lines << '  ' * indent + [label, value].join(': ')
        
      end

      lines << "\n"

      lines.concat scan_print(row_children, indent+1) if row_children.any?

    end

    lines
  end
  
end