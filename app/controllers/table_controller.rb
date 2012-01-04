class TableController < ApplicationController
  before_filter :require_user
  include TableHelper
  def new
    if (params[:type] == "topic")
      @thread = Topic.find_by_name(params[:name])
    else
      @thread = Puzzle.find(params[:id])
    end
    @table = @thread.tables.build({:priority=>"Normal"})
    @table.editor = current_or_anon_login
    create_table(@table,5,2)
    if @table.save
      text = render_to_string :partial => 'block', :locals => { :table => @table }
      # again, use juggernaut to do this.
      Juggernaut.send_to_channel( "create_workspace('#{javascript_escape text}'); init_table('#{@table.t_id}');", @table.thread.chat_id )
    end
    render :nothing => true
  end
  
  def delete
    logger.info "Destroying"
    @table = Table.find(params[:id])
    Juggernaut.send_to_channel( "$('#{@table.div_id}').remove()", @table.thread.chat_id )
    @table.destroy
    render :nothing => true
  end
  
  def edit
    @table = Table.find(params[:id])
    render :partial => 'edit', :locals => { :table => @table, :yourtext => nil }
  end

  def show
    @table = Table.find(params[:id])
    render :partial => 'show', :locals => { :table => @table, :yourtext => nil }
  end

  def update_cell
    # no need to be careful with this data
    @tablecell = TableCell.find(params[:id])
    @tablecell.contents = params[:text]
    @tablecell.save
    render :juggernaut => { :type => :send_to_channel, :channel => params[:channel] } do |page|
        page << "if ($('#{@tablecell.t_id}')) $('#{@tablecell.t_id}').value='#{javascript_escape @tablecell.contents}'; update_table('TB#{@tablecell.table_id}');"
    end
    render :nothing => true
  end

  def prioritize
    @table = Table.find(params[:id])
    return false if (params[:table][:priority] == @table.priority)
    if @table.update_attributes(params[:table])
      txt = render_to_string :partial => "show", :locals => { :table => @table }
      Juggernaut.send_to_channel("jug_table_update('#{@table.div_id}','#{javascript_escape txt}','#{@table.t_id}');", @table.thread.chat_id)
    end
    render :nothing => true
  end

  def update
    @table = Table.find(params[:id])
    if params[:raw] && params[:useraw]
      update_from_raw(table,params[:raw])
    end
    
    if @table.update_attributes(params[:table])
        # DON'T update here - use juggernaut to send the request. You need the chat id!
      txt = render_to_string :partial => "show", :locals => { :table => @table }
      Juggernaut.send_to_channel("jug_table_update('#{@table.div_id}','#{javascript_escape txt}','#{@table.t_id}');", @table.thread.chat_id)
      #render :juggernaut => { :type => :send_to_channel, :channel => @table.thread.chat_id } do |page|
      #  page << "jug_ws_update('#{@table.div_id}','#{javascript_escape txt}');"
      #end
    end
    render :nothing => true
  end

  def get_rc
    @table = Table.find(params[:id])
    if (params[:type] == "row")
      add_row(@table)
    else
      add_column(@table)
    end
    if @table.save
      text = render_to_string :partial => 'show', :locals => { :table => @table }
      # again, use juggernaut to do this.
      Juggernaut.send_to_channel( "jug_table_update('#{@table.div_id}','#{javascript_escape text}','#{@table.t_id}');", @table.thread.chat_id )
    end
    render :nothing => true
  end
end
