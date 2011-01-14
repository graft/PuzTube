class TableController < ApplicationController
  def new
    if (params[:type] == "topic")
      @thread = Topic.find_by_name(params[:name])
    else
      @thread = Puzzle.find(params[:id])
    end
    @table = @thread.tables.build({:priority=>"Normal"})
    if @table.save
      text = render_to_string :partial => 'block', :locals => { :table => @table }
      # again, use juggernaut to do this.
      Juggernaut.send_to_channel( "create_workspace('#{javascript_escape text}');", @table.thread.chat_id )
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

  def prioritize
    @table = Table.find(params[:id])
    return false if (params[:table][:priority] == @table.priority)
    if @table.update_attributes(params[:table])
      txt = render_to_string :partial => "show", :locals => { :table => @table }
      Juggernaut.send_to_channel("jug_ws_update('#{@table.div_id}','#{javascript_escape txt}');", @table.thread.chat_id)
    end
    render :nothing => true
  end

  def update
    @table = Table.find(params[:id])
    
    if @table.updated_at > Time.at(params[:locktime].to_i)
      render :partial => 'edit', :locals => { :table => @table, :yourtext => params[:table][:content] }
      return false
    elsif @table.update_attributes(params[:table])
      flash[:notice] = 'Table was successfully updated.'
      logger.info "Successfully updated, dunno what the deal is..."
        # DON'T update here - use juggernaut to send the request. You need the chat id!
      txt = render_to_string :partial => "show", :locals => { :table => @table }
      Juggernaut.send_to_channel("jug_ws_update('#{@table.div_id}','#{javascript_escape txt}');", @table.thread.chat_id)
      #render :juggernaut => { :type => :send_to_channel, :channel => @table.thread.chat_id } do |page|
      #  page << "jug_ws_update('#{@table.div_id}','#{javascript_escape txt}');"
      #end
      render :text => txt
      return false
    end
    render :nothing => true
  end
end
