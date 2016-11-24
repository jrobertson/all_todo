#!/usr/bin/env ruby

# file: all_todo.rb


require 'pxrowx'
require 'polyrex-headings'


class AllTodo

  def initialize(raw_s)
    
    s, _ = RXFHelper.read(raw_s)

    # remove the file heading     
    lines = s.lines
    lines.shift 3
    
    @fields = %w( todo heading when duration priority status note tags)
    declar = "<?ph schema='sections[title]/section[#{@fields.join(',')}]'" + 
        " format_masks[0]='[!todo]'?>"

    # add a marker to identify the headings after parsing the records
    
    s2 = lines.join.gsub(/^#+\s+/,'\0:')
    
    @px = PolyrexHeadings.new(declar + "\n" + s2).to_polyrex
    
    @px.each_recursive do |x, parent, level|

      todo = x.todo

      raw_status = todo.slice!(/\[.*\]\s+/)
      x.todo = todo
      
      status  = raw_status =~ /\[\s*x\s*\]/ ? 'done' : ''      
      x.status = status
            
      # is there a note?
      
      note = todo[/^note:\s+(.*)/i,1]
      
      if note and parent.is_a? PolyrexObjects::Section then
        
        parent.note = note
        x.delete
          
      end
      
      # is it a heading?
      
      heading = todo[/^:(.*)/,1]
      
      if heading then

        # does the heading contain tags?
        
        raw_tags = heading.slice!(/\s+#.*$/)
        x.tags = raw_tags[/#\s+(.*)/,1] if raw_tags
        x.heading = heading
        x.todo = ''        
        
      end
      
    end        

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
  
  def to_s()
    
    title = 'all_todo.txt'
    
    lines = [title, '=' * title.length]
    offset_level = 0
    
    @px.each_recursive do |x, parent, level, i|

      # is it a heading?
      
      if x.heading.length > 0 then
        
        lines << ''
        lines << "%s %s" % ['#' * (level+1), x.heading]
        offset_level = -(level + 1)

      else
        
        relative_level = level + offset_level
        indent = '  ' * relative_level
        
        status = x.status == 'done' ? 'x' : ' '
        todo = "%s[%s] %s" % [indent, status, x.todo]
        lines << '' if i == 0 and parent.heading.length > 0
        lines << todo
        
        lines << 'Note: ' + x.note + "\n" if x.note.length > 0
        
      end

    end
    
    lines << ['', '']

    lines.join("\n")    

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