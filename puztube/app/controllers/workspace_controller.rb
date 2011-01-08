class WorkspaceController < ApplicationController
  def new
    if (params[:type] == "topic")
      @thread = Topic.find_by_name(params[:name])
    else
      @thread = Puzzle.find(params[:id])
    end
    @workspace = @thread.workspaces.build
    if @workspace.save
      text = render_to_string :partial => 'block', :locals => { :workspace => @workspace }
      # again, use juggernaut to do this.
      render :juggernaut => { :type => :send_to_channel, :channel => @workspace.thread.chat_id } do |page|
        page << "create_workspace('#{javascript_escape text}');"
      end
    else
      render :nothing => true
    end
  end
  
  def delete
    logger.info "Destroying"
    @workspace = Workspace.find(params[:id])
    render :juggernaut => { :type => :send_to_channel, :channel => @workspace.thread.chat_id } do |page|
      page << "$('#{@workspace.div_id}').remove()"
    end
    @workspace.destroy
  end
  
  def edit
    @workspace = Workspace.find(params[:id])
    render :partial => 'edit', :locals => { :workspace => @workspace }
  end

  def update
    @workspace = Workspace.find(params[:id])
    
   if @workspace.update_attributes(params[:workspace])
      flash[:notice] = 'Workspace was successfully updated.'
      logger.info "Successfully updated, dunno what the deal is..."
        # DON'T update here - use juggernaut to send the request. You need the chat id!
      txt = render_to_string :partial => "show", :locals => { :workspace => @workspace }
      render :juggernaut => { :type => :send_to_channel, :channel => @workspace.thread.chat_id } do |page|
        page << "jug_ws_update('#{@workspace.div_id}','#{javascript_escape txt}');"
      end
    end
    render :nothing => true
 end
  
end
