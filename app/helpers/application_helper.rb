# Methods added to this helper will be available to all templates in the application.
require 'digest/sha1'
require 'csv'

module ApplicationHelper

  def send_chat(user,channel,text)
    @chat = Chat.new( { :user => user } )
    jc = { :type => :send_to_channel, :channel => channel }
    msg = "<b>#{user}:</b> #{ text }"
    sus = "subscribe_user('#{user}')"
    if (text.sub!(/^\/msg ([\w]*) /,''))
      # echo it
      jc[:type] = :send_to_client_on_channel
      jc[:client_id] = user
      msg = "<b style='color:red;'>PRIVATE to #{$1}:</b> #{ text }"
      render :juggernaut => jc do |page|
        page << "jug_chat_update('<li>#{javascript_escape sanitize_text msg}</li>');"
      end
      msg = "<b style='color:red;'>PRIVATE from #{user}:</b> #{ text }"
      jc[:type] = :send_to_client
      jc[:client_id] = $1
      channel = "private_to_#{$1}"
      sus = ''
    elsif (text.sub!(/^\/([\w]*) /,''))
      if $1 == "all"
        jc[:type] = :send_to_all
        msg = "<b style='color:red;'>BROADCAST from #{user}:</b> #{ text }"
      else
        jc[:type] = :send_to_channel
        msg = "<b style='color:red;'>OOC{#{channel}} #{user}:</b> #{ text }"
      end
      sus = ''
      channel = $1
      jc[:channel] = channel
    end
    @chat.text = text
    @chat.chat_id = channel
    if (@chat.save)
      # how do we render this?
      render :juggernaut => jc do |page|
        page << "jug_chat_update('<li>#{@chat.timeformat} #{javascript_escape sanitize_text msg}</li>'); #{sus}"
      end
    end
  end

  def javascript_escape(str)
    str.gsub(/\\|'/) { |c| "\\#{c}" }.gsub(/\n/,'\n')
  end
  
  def sanitize_text(str)
    sanitize(auto_link(str, :html => { :target => '_blank' }), :tags => %w(a b), :attributes => %w(href style target) )
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
    text = workspace.content.gsub(/\r\n/,"\n").gsub(/\A\n+/,'').sub(/\n+\z/,'').gsub(/\n\n+/,"\n\n")
    tags = []
    pre = []

    # protect tag contents
    tablecount = 0
    text.gsub!(/<([^>]+)>/) { |m| tags.push($1); "<#{(tags.size-1).to_s}>" }
    text.gsub!(/^>(.*?)(?=(^[^>]|\z))/m) { |m| quoteblock(s) } if OPTIONS[:quote]
    text.gsub!(/^[ \t](.*?)(?=(^[^ \t]|\z))/m) { |m| pre.push $1.gsub(/^[ \t]/,""); "<pre><pre#{pre.length-1}></pre>\n" } if OPTIONS[:pre]
    text.gsub!(/^(TAB|COMMA)\n(.*?)^END\1$/m) do |m|
      tablecount += 1
      table_html(send("array_#{$1}", $2), workspace, tablecount)
    end if OPTIONS[:tab]
    
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
    text.gsub!(/([^\w]?)\*(\S[^*]*\S|\S)\*(?!\w)/,"\\1<b>\\2</b>") if OPTIONS[:b]
    text.gsub!(/([^\w]?)\@(\S[^@]*?\S|\S)\@(?!\w)/,"\\1<strike>\\2</strike>") if OPTIONS[:s]    
    text.gsub!(/([^\w]?)_(\S[^_]*\S|\S)_(?!\w)/,"\\1<i>\\2</i>") if OPTIONS[:i]    
    text.gsub!(/--/,"&#8212;") if OPTIONS[:emdash]
    text.gsub!(/<pre(\d+)>/) { |c| pre[$1.to_i] } if OPTIONS[:pre]
    text.gsub!(/\b((https?|ftp|irc):\/\/[^\s\<]+)/i) { |m| tags.push refblock(m); "<#{(tags.size-1).to_s}>" } if OPTIONS[:http]    
    # restore tag contents
    text.gsub(/<(\d+)>/) { |m| "<#{tags[$1.to_i]}>" }
  end
  
  def expand(rows)
    max = rows.map{|r|r.length}.max
    rows.map!{|r| r + [''] * (max-r.length)}
  end
  
  def array_COMMA(csv)
    expand(CSV.parse(csv))
  end

  def array_TAB(tsv)
    expand(tsv.split("\n").map { |c| [ c.split("\t") ] })
  end

  def text_COMMA(rows)
    CSV.generate { |c| rows.each { |row| c << row } }
  end
  def text_TAB(rows)
    return rows.map { |c| c.join("\t") }.join("\n") + "\n"
  end

  def table_html(rows,workspace,count)
     # okay, we're going to go radical and render this as a table!
    return render :partial => 'workspace/table', :locals => { :workspace => workspace, :count => count, :rows => rows }
  end
  
  def update_table(workspace,table,row,col,txt)
    # first find the right table
    tc = 0
    updated = false
    text = workspace.content.clone
    text.gsub!(/^(TAB|COMMA)\n(.*?)^END\1($)/m) do |match|
      tc += 1
      if tc == table
        puts "Found the correct table in update_table"
        # split it according to the given rules and flee
        rows = send("array_#{$1}", $2)
        
        if row < rows.length && col < rows[row].length
          rows[row][col] = txt
          updated = true
        end
        "#{$1}\n#{send("text_#{$1}",rows)}END#{$1}#{$3}"
      else
        match
      end
    end
    workspace.update_attribute(:content,text) if updated
  end
  
  def emit_activity(puzzle,task)
    activity = Activity.new
    activity.puzzle_id = puzzle.id
    activity.hunt_id = puzzle.round.hunt_id
    activity.user_id = current_user.id
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
