#!/usr/bin/env ruby

# file: all_todo.rb


require 'px_todo'
require 'rexle-diff'


=begin
## start of code comments ######################################

how it should work
==================

Basic usage
-----------

the user ...

* creates the all_todo.txt (see the sample all_todo.txt file)
* runs AllTodo#to_s to refresh the all_todo.txt file with checkboxes
* identifies the todo items for that day by prefixing the item with an
  asterisk (*)
* runs AllTodo#export_today to generate the todo_daily.txt file
* crosses a few todo item checkboxes in the todo_daily.txt file and 
  saves the file
* runs AllTodo#update_today to update the completed todo items from the 
  todo_daily.txt into the all_todo.txt file
  - all_todo_detail.txt and all_todo_detail.xml is automatically updated

Syncing from all_todo_detail.txt 
---------------------------------

the user ...

* updates a few *when* fields in all_todo_detail.txt file
* runs AllTodo#sync_detail which updates the *when* fields in all_todo.xml

--------------------------------------------------

example file

all_todo.txt
------------

# Projects

## all_todo

[ ] Implement the secret new feature
[ ] Add a README file

## liveblog

Implement the saving of images from the web locally

# volunteering

* Meeting at Cafe X

## end of code comments ########################################
=end


class AllTodo < PxTodo

  def initialize(raw_s=nil, filepath: '.')
    
    if raw_s then
      
      super(raw_s, filepath: filepath) do |x|
        
        todo = x.title

        # is the to-do item selected for action today?
        today_item = todo.slice!(/^\*\s+/)      
        x.when = 'today' if today_item
        
        x.title = todo
        
      end        
    end
    
  end
  
  # generates the all_todo_detail.txt file contents
  #
  def detail()
    
    lines = []
    
    @px.each_recursive do |item, parent, level, i|

      lines << item.to_h.map \
          {|k,v| "%s%s: %s" % ['  ' * level, k, v]}.join("\n")
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
  
  # parses the all_todo_detail.txt file
  #
  def parse_detail(s)
    
    lines = s.lines
    lines.shift 3

    pr = PxRowX.new(lines.join, record_name: 'todo')
    pr.to_xml pretty: true    

  end

  
  # synchronises the when field
  #
  def sync(px, px2)
    
    results = []
    
    px.each_recursive do |x, parent|
      
      if x.when.length > 0 then

        basic_xpath = x.node.backtrack(use_attributes: false).to_xpath

        a = basic_xpath.split('/')
        a.shift # removes the root node reference
        
        s = if parent.heading.length > 0 then
          "heading='%s'" % parent.heading
        else
          "title='%s'" % parent.title
        end
        
        a[-3] << "[summary/#{s}]"
        a.last << "[summary/title='#{x.title}']"
        xpath = a.join('/')

        results << [xpath, x.when]
      end
    end
        
    results.each do |xpath, val|

      r = px2.element(xpath + '/summary/when')
      r2 = px.element(xpath + '/summary/when')
      next unless r

      a1, a2 = [r.text, val].map {|x| x.to_s.split(';').map(&:strip) }
      
      # return values which in both a1 and a2
      r.text = (a1 | a2).join('; ')

    end
    
    
  end

  
  def sync_all_todo()    
  
    # given all_todo.txt is loaded
    # load the master copy (all_todo.xml)

    px = Polyrex.new File.join(@filepath, 'all_todo.xml')  
    
    sync px, @px
    
  end
  
  
  # synchronises the all_todo_detail.txt file and updates the *when* field in 
  # the all_todo.xml file
  #
  def sync_detail()
    
    s = File.read File.join(@filepath, 'all_todo_detail.txt')
    
    px = Polyrex.new parse_detail(s)
    sync px, @px

  end

  def save(filepath=File.join(@filepath, 'all_todo.xml'))

    File.write filepath, self.to_px.to_xml(pretty: true)
    
    # also update the all_todo.txt  and all_todo_detail.txt
    
    # make a backup of the master copy (all_todo.txt) first
    if File.exists? File.join(@filepath, 'all_todo.txt') then
      FileUtils.cp File.join(@filepath, 'all_todo.txt'), 
          File.join(@filepath, 'all_todo.txt~')
    end
    
    File.write File.join(@filepath, 'all_todo.txt'), self.to_s        
    
    # backup the detail first
    if File.exists? File.join(@filepath, 'all_todo_detail.txt') then
      FileUtils.cp File.join(@filepath, 'all_todo_detail.txt'), 
          File.join(@filepath, 'all_todo_detail.txt~')
    end
    
    File.write File.join(@filepath, 'all_todo_detail.txt'), self.detail

    'saved'
    
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
        todo << '* ' if x.when =~ /today/
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

    pxtodo = PxTodo.new(file, filepath: @filepath, ignore_headings: true)

    # remove the id attributes
    px2 = pxtodo.to_px
    px2.xpath('//todo').each {|x| x.attributes.delete :id}

    # read the todo_daily_noid file
    px1noid = Polyrex.new(File.join(@filepath, 'todo_daily_noid.xml'))
    xml = px1noid.to_xml
    xml2 = px2.to_xml pretty: true

    # compare the 2 documents   
    doc = RexleDiff.new(xml, xml2).to_doc

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