class WorkspaceController < ApplicationController
  def new
    if (params[:type] == "topic")
      @thread = Topic.find_by_name(params[:name])
    elsif (params[:type] == "round")
      @thread = Round.find(params[:id])
    else
      @thread = Puzzle.find(params[:id])
    end
    @workspace = @thread.workspaces.build({:priority=>"Normal"})
    @workspace.editor = current_or_anon_login
    if @workspace.save
      text = render_to_string :partial => 'block', :locals => { :workspace => @workspace }
      emit_activity(@thread, "created a workspace") if params[:type] == "puzzle"
      # again, use juggernaut to do this.
      Juggernaut.send_to_channel( "create_workspace('#{javascript_escape text}');", @workspace.thread.chat_id )
    end
    render :nothing => true
  end
  
  def delete
    logger.info "Destroying"
    @workspace = Workspace.find(params[:id])
    Juggernaut.send_to_channel( "$('#{@workspace.div_id}').remove()", @workspace.thread.chat_id )
    @workspace.destroy
    render :nothing => true
  end
  
  def edit
    @workspace = Workspace.find(params[:id])
    render :partial => 'edit', :locals => { :workspace => @workspace, :yourtext => nil }
  end

  def show
    @workspace = Workspace.find(params[:id])
    render :partial => 'show', :locals => { :workspace => @workspace, :yourtext => nil }
  end

  def prioritize
    @workspace = Workspace.find(params[:id])
    return false if (params[:workspace][:priority] == @workspace.priority)
    if @workspace.update_attributes(params[:workspace])
      txt = render_to_string :partial => "show", :locals => { :workspace => @workspace }
      Juggernaut.send_to_channel("jug_ws_update('#{@workspace.div_id}','#{javascript_escape txt}');", @workspace.thread.chat_id)
    end
    render :nothing => true
  end

  def update
    @workspace = Workspace.find(params[:id])
    
    if @workspace.updated_at > Time.at(params[:locktime].to_i)
      render :partial => 'edit', :locals => { :workspace => @workspace, :yourtext => params[:workspace][:content] }
      return false
    elsif @workspace.update_attributes(params[:workspace])
      emit_activity(@workspace.thread,"edited workspace #{@workspace.title}") if @workspace.thread_type == "Puzzle"
      # DON'T update here - use juggernaut to send the request. You need the chat id!
      txt = render_to_string :partial => "show", :locals => { :workspace => @workspace }
      Juggernaut.send_to_channel("jug_ws_update('#{@workspace.div_id}','#{javascript_escape txt}');", @workspace.thread.chat_id)
      #render :juggernaut => { :type => :send_to_channel, :channel => @workspace.thread.chat_id } do |page|
      #  page << "jug_ws_update('#{@workspace.div_id}','#{javascript_escape txt}');"
      #end
      render :text => txt
      return false
    end
    render :nothing => true
  end
  
  def new_attachment
    # create the attachment
    @workspace = Workspace.find(params[:id])
    @asset = @workspace.assets.build(params[:asset])
    if @asset.save
      text = render_to_string :partial => 'asset', :locals => { :asset=> @asset }
      # again, use juggernaut to do this.
      render :juggernaut => { :type => :send_to_channel, :channel => @workspace.thread.chat_id } do |page|
        page << "insert_asset('#{@workspace.div_id}','#{javascript_escape text}');"
      end
    else
      render :juggernaut => { :type => :send_to_channel, :channel => @workspace.thread.chat_id } do |page|
        page << "alert('failed for some reason');"
      end
    end
    render :nothing => true
  end
  
  def delete_attachment
    @asset = Asset.find(params[:id])
    @workspace = Workspace.find(@asset.workspace_id)
    render :juggernaut => { :type => :send_to_channel, :channel => @workspace.thread.chat_id } do |page|
      page << "delete_asset('#{@workspace.div_id}','#{@asset.id}');"
    end
    @asset.destroy
    render :nothing => true
  end
end
