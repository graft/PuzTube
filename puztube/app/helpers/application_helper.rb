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
        page << "jug_chat_update('<li>#{@chat.dateformat} #{javascript_escape sanitize_text msg}</li>'); #{sus}"
      end
    end
  end

  def javascript_escape(str)
    str.gsub(/\\|'/) { |c| "\\#{c}" }.gsub(/\n/,' ')
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
                    :i => true,
                    :emdash => true,
                    :http => true,
                    :quote => false
                    }

  def texturize(text, options) 
    #warn "texturize: $text";

    # standardize newlines and collapse
    text.gsub!(/\r\n/,"\n")
    text.gsub!(/\A\n+/,'')
    text.sub!(/\n+\z/,'')
    text.gsub!(/\n\n+/,"\n\n")

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
    lines.each_index do |i|
      # lines starting with > -> <div class="quotation">
      if options[:quote] && lines[i].gsub!(/^>/,'')
        if i+1==lines.length
          content = lines.slice!(i,1).join("\n")
          content = "<div class=\"quotation\">\n#{content}\n</div>"
          lines.push(content)
        else
          (i+1...lines.length).each do |j|
            break if lines[j].gsub(/^>/,'').nil?
          end
        
          content = lines.slice!(i,j-i).join("\n")
#         content = texturize(content, { wiki => 0, http => 0 } );
          content = "<div class=\"quotation\">\n#{content}\n</div>"
          lines.insert(i+1, content);
        end
        # lines starting with space or tab -> <pre>
      elsif options[:pre] && !lines[i].gsub!(/\A[ \t]/,'').nil?
        if i+1==lines.length
          content = lines.slice!(i, 1).join("\n")
          lines.push("<pre><pre#{pre.length}></pre>")
        else
          (i+1...lines.length).each do |j|
            break if lines[j].gsub!(/\A[ \t]/,'').nil?
          end
          content = lines.slice!(i, j - i).join("\n")
          lines.insert(i+1,"<pre><pre#{pre.length}></pre>")
        end
        pre.push(content)
        # tables
      elsif options[:tab] && lines[i] =~ /^TAB/
        (i+1...lines.length).each do |j|
          break if lines[j] =~ /^ENDTAB/
        end
        content = lines.slice!(i + 1, j - i - 1).join("\n")+"\n"
        content = tsv_html(options,content)
        lines.slice!(i,2)
        lines.insert(i+1,content)
        # tables
      elsif options[:comma] && lines[i] =~ /^COMMA/
        (i+1...lines.length).each do |j|
          break if lines[j] =~ /^ENDCOMMA/
        end
        content = lines.slice!(i + 1, j - i - 1).join("\n") + "\n"
        #warn "comma: $content";
        content = csv_html(options,content)
        lines.slice!(i,2)
        lines.insert(i, content)
      end
    end

    # lists
    if options[:list]
      old = []
      lines.each_index do |i|
        if !lines[i].gsub!(/\A([\-\#]*)/,'').nil?
          #warn "\n$1$lines[$i]\n" if $1;
          lines[i] = "<li> #{lines[i]} </li>" if $1.size > 0
          new = $1.split(//)
          #warn "old " . join('',@old)  . " new " . join('',@new) .  "\n";
          changes = ''
          diff = 0
          old.each_index do |diff|
            break if (new[diff] != old[diff])
          end
          diff = diff+1 if (new[diff] == old[diff])
          #warn "diff $diff\n";
          (diff...old.length).each do |j|
            changes = (' ' * j) + ApplicationHelper::LIST_CLOSE_TAGS[old[j]] + "\n" + changes
          end
          (diff...new.length).each do |j|
            changes += (' ' * j) + ApplicationHelper::LIST_OPEN_TAGS[new[j]] + "\n"
          end
          lines[i] = changes + (' ' * new.size) + lines[i]
          old = new
        end
      end

      old.each_index do |j|
        lines.push((' ' * j) + ApplicationHelper::LIST_CLOSE_TAGS[old[j]])
      end
    end 

    # paragraphs
    if options[:p]
      lines.each_index do |i|
        if lines[i] == ""
          lines[i] = "</p>\n\n<p>"
        end
      end

      lines.unshift("<p>\n")
      lines.push("</p>\n")
    end

    text = lines.join("\n")
        
    # bold
    if options[:b]
      text.gsub!(/([^\w]?)\*(\S[^*]*\S|\S)\*(?!\w)/,"\\1<b>\\2</b>")
    end
    
    # italic
    if options[:i]
      text.gsub!(/([^\w]?)_(\S[^_]*\S|\S)_(?!\w)/,"\\1<i>\\2</i>")
    end
        
    # emdash
    if options[:emdash]
      text.gsub!(/--/,"&#8212;")
    end

    logger.info "Text is >>#{text}<<"

    # restore pre contents
    text.gsub!(/<pre(\d+)>/) do |c|
      logger.info "Restoring >>#{$1}<<"
      pre[$1.to_i]
    end if options[:pre]

    # http links
    if options[:http]
      text.gsub!(/\b((https?|ftp|irc):\/\/[^\s\<]+)/i) do |m|
        tags.push("a href=\"#{m}\">#{m}</a")
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
    return "<table border=\"1\">\n<tr>\n" +
        rows.map { |c|
                   "  <td>" + 
                 c.join("</td>\n  <td>") +
                 "</td>\n"
                 }.join("</tr>\n<tr>\n") + "</tr>\n</table>\n"
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
    html = array_table(array)

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
    return array_html(options, csv_array(csv))
  end
  
  def tsv_html(options,tsv)
    return array_html(options, tsv_array(tsv))
  end


end
