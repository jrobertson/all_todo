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
    
    @fields = %w( title heading when duration priority status note tags)
    declar = "<?ph schema='items[title]/todo[#{@fields.join(',')}]'" + 
        " format_masks[0]='[!title]'?>"

    # add a marker to identify the headings after parsing the records
    
    s2 = lines.join.gsub(/^#+\s+/,'\0:')
    
    @px = PolyrexHeadings.new(declar + "\n" + s2).to_polyrex
    
    @px.each_recursive do |x, parent, level|

      todo = x.title

      # is the to-do item selected for action today?
      today_item = todo.slice!(/^\*\s+/)
      
      x.when = 'today' if today_item

      raw_status = todo.slice!(/\[.*\]\s+/)
      x.title = todo

      status  = raw_status =~ /\[\s*x\s*\]/ ? 'done' : ''      

      x.status = status
            
      # is there a note?
      
      note = todo[/^note:\s+(.*)/i,1]
      
      if note and parent.is_a? PolyrexObjects::Todo then
        
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
        x.title = ''        
        
      end
      
    end        

  end
  
  def detail()
    
    lines = []
    
    @px.each_recursive do |item, parent, level, i|

      lines << item.to_h.map {|k,v| "%s%s: %s" % ['  ' * level, k, v]}.join("\n")
      lines << ['']
      
    end    
   
    ([s='all_todo_detail.txt', '=' * s.length, '', ''] + lines).join("\n")
    
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
    
    lines = []
    offset_level = 0
    
    @px.each_recursive do |x, parent, level, i|

      # is it a heading?
      
      if x.heading.length > 0 then
        
        lines << ''
        lines << '' if level == 0
        lines << "%s %s" % ['#' * (level+1), x.heading]
        offset_level = -(level + 1)
        
        lines.last << ' # ' + x.tags if x.tags.length > 0

      else
        
        relative_level = level + offset_level
        indent = '  ' * relative_level
        
        status = x.status == 'done' ? 'x' : ' '
        
        todo = []
        todo << '* ' if x.when == 'today'
        todo << "%s[%s] %s" % [indent, status, x.title]
        
        lines << '' if i == 0 and parent.heading.length > 0
        lines << todo.join
        
        lines << "%s  Note: %s\n" % [indent, x.note] if x.note.length > 0
        
      end

    end
    
    lines << ['', '']

    title = 'all_todo.txt'
    
    ([title, '=' * title.length] + lines[1..-1]).join("\n")    

  end

  # prints out the to-do list for today
  
  def today(day='today')

    px = @px    

    raw_rows = px.find_all_by_todo_when(day).map do |x|

      headings = fetch_heading(x.parent)

      # print the headings

      a = headings.reverse.map.with_index do |s, i|
        "%s %s" % ['#'* (i+1), s]
      end

      status = x.status == 'done' ? 'x' : ' '
      
      todo_lines = []

      todo_lines << "[%s] %s" % [status, x.title]

      x.each_recursive do |item, parent, level|
        n ||= level - 1
        status = item.status == 'done' ? 'x' : ' '
        todo_lines << "%s[%s] %s" % ['  ' * (level - n), status, item.title]
      end
      
      [a, todo_lines.join("\n")]
    end

    lines = []

    raw_rows.group_by(&:first).each do |heading, items|
      lines << heading.join("\n") << ''
      lines << items.map{|x| x[1..-1]}.join("\n") << ''
    end

    filename = 'todo_daily.txt'
    ([filename, '=' * filename.length, ''] + lines).join("\n")

  end
  
  private

  def fetch_heading(item, a=[])
    a << item.heading
    a.concat fetch_heading(item.parent) if item.parent?
    a
  end
  
end