# Methods added to this helper will be available to all templates in the application.
require 'digest/sha1'

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
  
  
  def comment_format(str)
    texturize(str,ApplicationHelper::DEFAULT_OPTIONS) # also replace COMMA/ENDCOMMA stuff
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

  DEFAULT_OPTIONS = { :p => true,
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

  def texturize(text, options) 
    #warn "texturize: $text";

    # standardize newlines and collapse
    text = text.gsub(/\r\n/,"\n").gsub(/\A\n+/,'').sub(/\n+\z/,'').gsub(/\n\n+/,"\n\n")

    tags = []
    
    # protect tag contents
    text.gsub!(/<([^>]+)>/) do |match|
      tags.push($1)
      "<#{(tags.size-1).to_s}>"
    end
    lines = text.split(/\n/)

    # protected <pre> blocks
    pre = []
    j = 0
    
    # fuck this stuff

   
    #quote blocks
    text.gsub!(/^>(.*?)(?=(^[^>]|\z))/m) do |match|
      "<div class='quotation'>\n#{$1.sub(/^>/,"")}\n</div>\n"
    end if options[:quote]
    
    #pre blocks
    text.gsub!(/^[ \t](.*?)(?=(^[^ \t]|\z))/m) do |match|
      pre.push $1.gsub(/^[ \t]/,"")
      "<pre><pre#{pre.length-1}></pre>\n"
    end if options[:pre]
    
    text.gsub!(/^TAB\n(.*?)^ENDTAB$/m) do |match|
      tsv_html(options,$1)
    end if options[:tab]
    
    text.gsub!(/^COMMA\n(.*?)^ENDCOMMA($|\z)/m) do |match|
      csv_html(options,$1)
    end if options[:comma]
    
    
    # lists
    if options[:list]
      text.gsub!(/^([#-]+.*?)(?=^[^#-]|\z)/m) do |match|
        #warn "\n$1$lines[$i]\n" if $1;
        old = ""
        match.gsub!(/^([#-]+)(.*?)$/) do |m|
          line = "<li> #{$2} </li>" #if $2.size > 0
          new = $1
          changes = ''
          diff = 0
          [old.length,new.length].max.times do |d|
            diff = d
            break if (new[d] != old[d])
          end
          diff = diff+1 if new == old
          (diff...old.length).each do |j|
            changes = (' ' * j) + ApplicationHelper::LIST_CLOSE_TAGS[old[j].chr] + "\n" + changes
          end
          (diff...new.length).each do |j|
            changes += (' ' * j) + ApplicationHelper::LIST_OPEN_TAGS[new[j].chr] + "\n"
          end
          old = new
          changes + (' ' * new.size) + line
        end

        old.length.times do |j|
          match << (' ' * j) + ApplicationHelper::LIST_CLOSE_TAGS[old[j].chr]
        end
        match
      end
    end 
    
     # paragraphs
    if options[:p]
      text.gsub!(/^$/,"</p>\n\n<p>") if options[:p]
      text = "<p>\n#{text}</p>\n"
    end

    # bold
    if options[:b]
      text.gsub!(/([^\w]?)\*(\S[^*]*\S|\S)\*(?!\w)/,"\\1<b>\\2</b>")
    end
    
    # strike
    if options[:s]
      text.gsub!(/([^\w]?)\@(\S[^@]*?\S|\S)\@(?!\w)/,"\\1<strike>\\2</strike>")
    end
    
    # italic
    if options[:i]
      text.gsub!(/([^\w]?)_(\S[^_]*\S|\S)_(?!\w)/,"\\1<i>\\2</i>")
    end
        
    # emdash
    if options[:emdash]
      text.gsub!(/--/,"&#8212;")
    end

    #logger.info "Text is >>#{text}<<"

    # restore pre contents
    text.gsub!(/<pre(\d+)>/) do |c|
      logger.info "Restoring >>#{$1}<<"
      pre[$1.to_i]
    end if options[:pre]

    # http links
    if options[:http]
      text.gsub!(/\b((https?|ftp|irc):\/\/[^\s\<]+)/i) do |m|
        tags.push("a href=\"#{m}\" target=\"_blank\">#{m}</a")
        "<#{(tags.size-1).to_s}>"
      end
    end
    

    # restore tag contents
    text.gsub!(/<(\d+)>/) do |m|
      "<#{tags[$1.to_i]}>"
    end
    
    #warn "texturized: $text";
    
    return text
  end

  def csv_array(csv)
    # cases where the cell is """text"""
    csv.gsub!(/(\A|,|\n)"""/,"\\1\"&quot;")
    csv.gsub!(/"""(\z|,|\n)/,"&quot;\"\\1")
    csv.gsub!(/""/,"&quot;")
    
    rows = []
    i = 0
    while (csv.size > 0) do
      if csv.gsub!(/\A[ \t]*"([^"]*)"[ \t]*(,|\n|\z)/,'')
        #warn "1: $1 ($2) " . ($2 eq "\n");
        cell = $1
        terminator = $2
        cell.gsub!(/&quot;/,'"')
        rows[i] ||= []
        rows[i].push(cell)
        i += 1 if (terminator == "\n")
      elsif csv.sub!(/\A(.*?)(,|\n|\z)/,'')
        #warn "2: $1";
        rows[i] ||= []
        rows[i].push($1)
        i += 1 if ($2 == "\n")
      else
        #warn "3: $1";
        rows[i].push($1)
        csv = ''
      end
    end
    
    return rows
  end

  def tsv_array(tsv)
    return tsv.split("\n").map { |c| [ c.split("\t") ] }
  end

  def array_table(rows)
    max = rows.map{|r|r.length}.max
    rows.map!{|r| r + [''] * (max-r.length)}
      
    return "<table class='neattable' border=\"1\">\n<tr>\n#{
        rows.map { |c| "<td>#{ c.join("</td>\n<td>") }</td>\n" }.join("</tr>\n<tr>\n")
        }</tr>\n</table>\n"
  end
  
  def cell_csv(cell)
    if cell =~ /[,"\n]/
      cell.gsub!(/"/,'""')
      cell = '"' + cell + '"'
    end
    return cell
  end

        
  def array_csv(rows)
    return rows.map { |c| c.map { |d| cell_csv(d) }.join(",") }.join("\n") + "\n"
  end

  def array_tsv(rows)
    return rows.map { |c| c.join("\t") }.join("\n") + "\n"
  end
  

  def array_html(options,array)
    html = array_table array

    if csv_link = options[:csvlink]
      encoded = array_csv(array)
      encoded.gsub!(/([^a-zA-Z0-9_.-])/) do |c|
        uc sprintf("%%%02x",ord(c))
      end
      html += "<a href=\"#{csv_link}?csv=#{encoded}\">CSV</a> "
    end

    if tsv_link = options[:tsvlink]
        encoded = array_tsv(array)
        encoded.gsub!(/([^a-zA-Z0-9_.-])/) do |c|
          sprintf("%%%02x",?c).upcase
        end
        html += "<a href=\"#{tsv_link}?tsv=#{encoded}\">TSV</a> "
    end

    return html
  end

        
  def csv_html(options,csv)
    #return "%%#{csv}$$"
    return array_html options, csv_array(csv)
  end
  
  def tsv_html(options,tsv)
    return array_html(options, tsv_array(tsv))
  end

  def recent_broadcasts
    @recent_broadcasts ||= Chat.find(:all, :conditions => { :chat_id => "all" }, :order => "created_at DESC", :limit => 2)  
  end
end
