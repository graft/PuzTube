# Methods added to this helper will be available to all templates in the application.
require 'digest/sha1'
require 'csv'
#require 'push'

module ApplicationHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper 

  def get_id channel
    id = channel.scan(/^\w+-([0-9]+)/).flatten.first
  end

  def send_chat(user,channel,text)
    @chat = Chat.new( { :user => user } )
    @chat.text = sanitize_text text
    @chat.chat_id = channel
    if (@chat.save)
      logger.info "Pushing chat request to channel #{channel}"
      Push.send :command => "chat", :channel => channel, :chat => @chat
    end
  end

  def with_link(user)
    "<a href=\"/users/#{user}\" target=\"blank\">#{user}</a>"
  end

  def main_host
    PuzTube.main_host
  end

  def node_host
    PuzTube.node_host
  end

  def javascript_escape(str)
    (str || "").gsub(/\\|'/) { |c| "\\#{c}" }.gsub(/\n/,'\n')
  end

  def quote_escape(str)
    (str || "").gsub(/"/,'&quot;')
  end
  
  def strip_html(str)
    str.sub("<","&lt;")
  end
  
  def sanitize_text(str)
    ActionController::Base.helpers.sanitize str, :tags => %w(a b), :attributes => %w(href style target)
  end

  def current_or_anon_login
    if (current_user)
      return current_user.login
    else
      session[:anon_id] ||= Digest::SHA1.hexdigest(Time.now.to_s).slice(0,5)
      return "anon_"+session[:anon_id]
    end
  end

  LIST_OPEN_TAGS = { '#' => '<ol>',
                   '-' => '<ul>' }
  LIST_CLOSE_TAGS = { '#' => '</ol>',
                    '-' => '</ul>' }

  OPTIONS = { :p => true,
                    :pre => true,
                    :list => true,
                    :tab => true,
                    :comma => true,
                    :b => true,
                    :s => true,
                    :i => true,
                    :emdash => true,
                    :http => true,
                    :quote => false
                    }
  def quoteblock(s)
    "<div class='quotation'>\n#{s.sub(/^>/,"")}\n</div>\n"
  end
  def refblock(m)
    "a href=\"#{m}\" target=\"_blank\">#{m}</a"
  end

  def comment_format(workspace) 
    text = (workspace.content || "").gsub(/\r\n/,"\n").gsub(/\A\n+/,'').sub(/\n+\z/,'').gsub(/\n\n+/,"\n\n")
    tags = []
    pre = []
    tables = []

    # protect tag contents
    tablecount = 0
    gridcount = 0
    text.gsub!(/<([^>]+)>/) { |m| tags.push($1); "<#{(tags.size-1).to_s}>" }
    text.gsub!(/^>(.*?)(?=(^[^>]|\z))/m) { |m| quoteblock(s) } if OPTIONS[:quote]
    text.gsub!(/^[ \t](.*?)(?=(^[^ \t]|\z))/m) { |m| pre.push $1.gsub(/^[ \t]/,""); "<pre><pre#{pre.length-1}></pre>\n" } if OPTIONS[:pre]
    text.gsub!(/^(TAB|COMMA)\n(.*?)^END\1$/m) do |m|
      tablecount += 1
      tables.push table_html(send("array_#{$1}", $2), workspace, tablecount)
      "<table#{tables.length-1}>"
    end if OPTIONS[:tab]
    text.gsub!(/^GRID ([0-9]+)x([0-9]+)\n(.*?)^ENDGRID$/m) do |m|
      gridcount += 1
      tables.push grid_html(array_GRID($3,$1.to_i,$2.to_i),workspace,gridcount)
      "<table#{tables.length-1}>"
    end
    
    # lists
    if OPTIONS[:list]
      text.gsub!(/^([#-]+.*?)(?=^[^#-]|\z)/m) do |match|
        old = ""
        match.gsub!(/^([#-]+)(.*?)$/) do |m|
          new = $1
          changes = ''
          diff = 0
          [old.length,new.length].max.times { |d| break if (new[diff = d] != old[d]) }
          diff += 1 if new == old
          (diff...old.length).each do |j|
            changes = (' ' * j) + LIST_CLOSE_TAGS[old[j].chr] + "\n" + changes
          end
          (diff...new.length).each do |j|
            changes += (' ' * j) + LIST_OPEN_TAGS[new[j].chr] + "\n"
          end
          old = new
          changes + (' ' * new.size) + "<li> #{$2} </li>"
        end
        old.length.times do |j|
          match << (' ' * j) + LIST_CLOSE_TAGS[old[j].chr]
        end
        match
      end
    end 
 
    text = text.gsub(/^$/,"</p>\n\n<p>").sub(/\A/,"<p>\n").sub(/\z/,"</p>\n") if OPTIONS[:p]
    text.gsub!(/img:([\w]*\.[\w]*)/,"<img src=/uploads/\\1>")
    text.gsub!(/img\{(\d*)x(\d*)\}:([\w]*\.[\w]*)/) { |m| "<img style='#{$1.length > 0 ? "width: #{$1}px; " : ""}#{$2.length > 0 ? "height: #{$2}px; " : ""}' src=/uploads/#{$3}>" }
    text.gsub!(/([^\w]?)\*(\S[^*]*\S|\S)\*(?!\w)/,"\\1<b>\\2</b>") if OPTIONS[:b]
    text.gsub!(/([^\w]?)\@(\S[^@]*?\S|\S)\@(?!\w)/,"\\1<strike>\\2</strike>") if OPTIONS[:s]    
    text.gsub!(/([^\w]?)_(\S[^_]*\S|\S)_(?!\w)/,"\\1<i>\\2</i>") if OPTIONS[:i]    
    text.gsub!(/--/,"&#8212;") if OPTIONS[:emdash]
    text.gsub!(/\b((https?|ftp|irc):\/\/[^\s\<]+)/i) { |m| tags.push refblock(m); "<#{(tags.size-1).to_s}>" } if OPTIONS[:http]    
    text.gsub!(/<pre(\d+)>/) { |c| pre[$1.to_i] } if OPTIONS[:pre]
    text.gsub!(/<table(\d+)>/) { |c| tables[$1.to_i] } if OPTIONS[:tab]
    # restore tag contents
    text.gsub(/<(\d+)>/) { |m| "<#{tags[$1.to_i]}>" }.html_safe
  end
  
  def expand(rows)
    max = rows.map{|r|r.length}.max
    rows.map!{|r| r + [nil] * (max-r.length)}
  end
  
  def array_COMMA(csv)
    begin
    expand(CSV.parse(csv.gsub(/, "/,',"')))
    rescue CSV::IllegalFormatError
      ["PARSE ERROR"]
    end
  end

  def array_GRID(csv,rows,cols)
    begin
    arr = CSV.parse(csv.gsub(/, "/,',"'))
    arr.map!{|r| r.take(cols) + [nil] * [cols-r.length,0].max}
    arr = arr.take(rows)  + Array.new([rows-arr.length,0].max) { [nil] * cols }
    rescue CSV::IllegalFormatError
      ["PARSE ERROR"]
    end
  end

  def array_TAB(tsv)
    expand(tsv.split("\n").map { |c| c.split("\t") })
  end

  def text_COMMA(rows)
    #rows.map { |row| CSV.generate_line row }.join("\n")+ "\n"
    CSV.generate { |c| rows.each { |row| c << row } }
  end
  alias :text_GRID :text_COMMA
  def text_TAB(rows)
    return rows.map { |c| c.join("\t") }.join("\n") + "\n"
  end

  GRID_COLORS = {
    "!" => "grid_black",
    "@" => "grid_brown",
    "#" => "grid_red",
    "$" => "grid_orange",
    "%" => "grid_yellow",
    "^" => "grid_green",
    "&" => "grid_blue",
    "*" => "grid_purple" }

  def grid_html(rows,workspace,count)
    return render :partial => 'workspace/grid', :locals => { :workspace => workspace, :count => count, :rows => rows, :show_div => true }
  end

  def update_grid(workspace,grid,row,col,txt)
    tc = 0
    rows = nil
    txt = nil if txt.length == 0
    text = workspace.content.gsub(/\r/,"")
    text.gsub!(/^GRID ([0-9]+)x([0-9]+)\n(.*?)^ENDGRID($)/m) do |match|
      tc += 1
      if tc == grid
        rows = array_GRID($3,$1.to_i,$2.to_i)
        rows[row][col] = txt if row < rows.length && col < rows[row].length
        "GRID #{$1}x#{$2}\n#{text_GRID(rows)}ENDGRID#{$4}"
      else
        match
      end
    end
    workspace.update_attribute(:content,text) if rows
  end
  
  def table_html(rows,workspace,count)
     # okay, we're going to go radical and render this as a table!
    return render :partial => 'workspace/table', :locals => { :workspace => workspace, :count => count, :rows => rows, :show_div => true }
  end

  def update_table(workspace,table,row,col,txt)
    # first find the right table
    tc = 0
    rows = nil
    txt = nil if txt.length == 0 || txt == ":" # might as well prevent quotes
    text = workspace.content.clone
    text.gsub!(/^(TAB|COMMA)\n(.*?)^END\1($)/m) do |match|
      tc += 1
      if tc == table
        rows = send("array_#{$1}", $2)
        logger.info "Old text was |#{$2}|"
        rows[row][col] = txt if row < rows.length && col < rows[row].length
        x = "#{$1}\n#{send("text_#{$1}",rows)}END#{$1}#{$3}"
        logger.info "Table text is now |#{x}|"
        x
      else
        match
      end
    end
    workspace.update_attribute(:content,text) if rows
  end
  
  def expand_table(workspace,table,type)
    # first find the right table
    tc = 0
    rows = nil
    logger.info "Expanding table #{workspace.table_id(table)}"
    text = workspace.content.clone
    text.gsub!(/^(TAB|COMMA)\n(.*?)^END\1($)/m) do |match|
      tc += 1
      if tc == table
        # split it according to the given rules and flee
        rows = send("array_#{$1}", $2)
        logger.info "Found the table."
        if (type == "col")
          rows.map!{ |r| r + [nil] }
        elsif rows.length > 0
          rows.push( [nil] * rows[0].length )
        end
        "#{$1}\n#{send("text_#{$1}",rows)}END#{$1}#{$3}"
      else
        match
      end
    end
    workspace.update_attribute(:content,text) if rows
    rows
  end
  
  def emit_activity(puzzle,task)
    activity = Activity.new
    activity.puzzle_id = puzzle.id
    activity.hunt_id = puzzle.round.hunt_id
    activity.user_id = current_user.id
    activity.task = task
    activity.save
  end

  def time_diff(time)
    case time
    when 0..3540 then return (time/60).to_i.to_s+' min'
    when 3541..3600 then return '1 hr' # 3600 = 1 hour
    when 3601..82800 then return ((time+99)/3600).round(1).to_s+' hrs'
    when 82801..86400 then return '1 day' # 86400 = 1 day
    when 86401..518400 then return ((time+800)/(60*60*24)).round(1).to_s+' days'
    when 518400..1036800 then return '1 wk'
    end
    return ((time+180000)/(60*60*24*7)).to_i.to_s+' wks'
  end

  def recent_broadcasts
    @recent_broadcasts ||= Chat.find(:all, :conditions => { :chat_id => "all" }, :order => "created_at DESC", :limit => 2)  
  end
end
