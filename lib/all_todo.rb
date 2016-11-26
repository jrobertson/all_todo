#!/usr/bin/env ruby

# file: all_todo.rb


require 'px_todo'
require 'rexle-diff'


class AllTodo < PxTodo

  def initialize(raw_s, filepath: '.')
    
    super(raw_s, filepath: filepath) do |x|
      
      todo = x.title

      # is the to-do item selected for action today?
      today_item = todo.slice!(/^\*\s+/)      
      x.when = 'today' if today_item
      
      x.title = todo
      
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
  
  # generates the todo_daily.txt file
  
  def export_today()
    
    ftxt, fxml, fnoidxml = %w(.txt .xml _noid.xml).map{|x| 'todo_daily' + x}
    
    File.write File.join(@filepath, ftxt), self.today()        
    
    a = self.to_px.find_all_by_todo_when 'today'

    px = Polyrex.new(schema="items[title]/todo[#{@fields.join(', ')}]")
    a.each {|x| px.add x }

    File.write File.join(@filepath, fxml), px.to_xml(pretty: true)
    
    px.xpath('//todo').each {|x| x.attributes.delete :id}
    File.write File.join(@filepath, fnoidxml), px.to_xml(pretty: true)
    
  end
  
  def parse_detail(s)
    
    lines = s.lines
    lines.shift 3
    pr = PxRowX.new(lines.join)
    pr.to_xml pretty: true    

  end

  def save(filepath=File.join(@filepath, 'all_todo.xml'))

    File.write filepath, @px.to_xml(pretty: true)

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
  
  def today(day='today', filename: 'todo_daily.txt')

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

    lines = raw_rows.group_by(&:first).inject([]) do |r, pair|
      heading, items = pair
      r << heading.join("\n") << '' << items.map{|x| x[1..-1]}.join("\n") << ''
    end

    ([filename, '=' * filename.length, ''] + lines).join("\n")

  end
  
  def update_today(file='todo_daily.txt')

    # parse the newest todo_daily.txt file
    pxtodo = PxTodo.new(file, filepath: @filepath)

    # remove the id attributes
    px2 = pxtodo.to_px
    px2.xpath('//todo').each {|x| x.attributes.delete :id}
    
    # read the todo_daily_noid file
    px1noid = Polyrex.new(File.join(@filepath, 'todo_daily_noid.xml'))
    
    # compare the 2 documents   
    doc = RexleDiff.new(px1noid.to_xml, px2.to_xml).to_doc
    
    a = doc.xpath('//todo/summary/status[@created]../.')
    
    # update the all_todo document    
    # first we need to find the ids
    
    px1 = Polyrex.new(File.join(@filepath, 'todo_daily.xml'))
    
    statuses = a.map do |node|

       e = px1.element("//summary[contains(title,'#{node.text('title')}')]")
       [e.parent.attributes[:id], node.text('status') ]
      
    end
    
    statuses.each do |id, status|
      
      todo = @px.find_by_id id
      todo.status = status
      
    end

  end
  
  private

  def fetch_heading(item, a=[])
    a << item.heading
    a.concat fetch_heading(item.parent) if item.parent?
    a
  end
  
end