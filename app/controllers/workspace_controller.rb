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
      Push.send :command => "new workspace", :channel => @workspace.thread.chat_id, :workspace => @workspace.id
      emit_activity(@thread, "created a workspace") if params[:type] == "puzzle"
    end
    render :nothing => true
  end
  
  def delete
    @workspace = Workspace.find(params[:id])
    Push.send :command => "destroy workspace", :channel => @workspace.thread.chat_id, :workspace => @workspace.div_id
    @workspace.destroy
    render :nothing => true
  end
  
  def edit
    @workspace = Workspace.find(params[:id])
    render :partial => 'edit', :locals => { :workspace => @workspace, :yourtext => nil }
  end

  def show
    @workspace = Workspace.find(params[:id])
    if (params[:c])
      render :partial => 'block', :locals => { :workspace => @workspace, :yourtext => nil }
    else
      render :partial => 'show', :locals => { :workspace => @workspace, :yourtext => nil }
    end
  end

  def prioritize
    @workspace = Workspace.find(params[:id])
    return false if (params[:workspace][:priority] == @workspace.priority)
    if @workspace.update_attributes(params[:workspace])
      Push.send :command => "update workspace", :channel => @workspace.thread.chat_id, :workspace => @workspace.id, :container => @workspace.div_id
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
      Push.send :command => "update workspace", :channel => @workspace.thread.chat_id, :workspace => @workspace.id, :container => @workspace.div_id
    end
    render :nothing => true
  end
  
  def update_cell
    @workspace = Workspace.find(params[:ws])
    # see if it is a table or a grid
    if params[:table]
      table,row,col = m.captures.map{|i|i.to_i}
      update_table(@workspace,table,row,col,params[:text])
      puts "Table text is |#{params[:text]}|"
      Push.send :command => "update table cell", 
        :channel => @workspace.thread.chat_id, 
        :cell => params[:cell], 
        :text => javascript_escape(params[:text]), 
        :table => @workspace.table_id(table)
    elsif params[:grid]
      grid,row,col = [ params[:grid].to_i, params[:row].to_i, params[:col].to_i ]
      update_grid(@workspace,grid,row,col,params[:text])
      Push.send :command => "update grid cell", 
        :channel => @workspace.thread.chat_id, 
        :ws => params[:ws],
        :grid => grid,
        :row => row,
        :col => col,
        :text => javascript_escape(params[:text])
    else
      render :nothing => true
      return
    end
    emit_activity(@workspace.thread,"edited workspace #{@workspace.title}") if @workspace.thread_type == "Puzzle"
    render :nothing => true
  end

  def add_rc
    @workspace = Workspace.find(params[:id])
    table = params[:table].to_i
    logger.info "Expanding a table."
    rows = expand_table(@workspace,table,params[:type])

    if rows
      emit_activity(@workspace.thread,"edited workspace #{@workspace.title}") if @workspace.thread_type == "Puzzle"
      Push.send :command => "update workspace", :channel => @workspace.thread.chat_id, :workspace => @workspace.id, :container => @workspace.div_id
    end
    render :nothing => true;
  end
  
  def new_attachment
    # create the attachment
    @workspace = Workspace.find(params[:id])
    @asset = @workspace.assets.build(params[:asset])
    if @asset.save
      text = render_to_string :partial => 'asset', :locals => { :asset=> @asset }
      Push.send :command => "new asset", :channel => @workspace.thread.chat_id, :workspace => @workspace.div_id, :text => text
    end
    render :nothing => true
  end
  
  def delete_attachment
    @asset = Asset.find(params[:id])
    @workspace = Workspace.find(@asset.workspace_id)
    Push.send :command => "destroy attachment", :channel => @workspace.thread.chat_id, :workspace => @workspace.div_id, :asset => @asset.id
    @asset.destroy
    render :nothing => true
  end
end
