class WorkspaceController < ApplicationController
  def create
    @workspace = Workspace.create(:thread_id => params[:thread_id],
                                 :thread_type => params[:thread_type],
                                 :workspace_type => params[:workspace_type],
                                 :priority => "Normal")

    @workspace.setup_type

    if @workspace.save
      Push.send :command => "new workspace", 
        :channel => @workspace.thread.chat_id, 
        :workspace => @workspace.render
      emit_activity(@workspace.thread, "created a workspace") if params[:thread_type] == "Puzzle"
    end
    render :nothing => true
  end
  
  def delete
    @workspace = Workspace.find(params[:id])
    @workspace.priority = 'Hidden'

    Push.send :command => "update workspace", :channel => @workspace.thread.chat_id, :workspace => @workspace.render

    @workspace.thread_id = nil
    @workspace.thread_type = nil
    @workspace.save
    render :nothing => true
  end
  
  def table
    @workspace = Workspace.find(params[:id])

    emit_activity(@workspace.thread,"edited workspace #{@workspace.title}") if @workspace.thread_type == "Puzzle"
    if params[:add]
      @workspace.add_row if params[:add] == "row"
      @workspace.add_col if params[:add] == "col"
      @workspace.save
      Push.send :command => "update workspace", :channel => @workspace.thread.chat_id, :workspace => @workspace.render
    end
    if params[:update]
      @workspace.update_cell params[:row], params[:col], params[:update]
      @workspace.save
      Push.send :command => "update cell", :channel => @workspace.thread.chat_id,
        :workspace => @workspace.id, :row => params[:row].to_i, :col => params[:col].to_i,
        :update => params[:update]
    end

    render :nothing => true
  end

  def update
    @workspace = Workspace.find(params[:id])
    
    if @workspace.updated_at > Time.zone.parse(params[:locktime])
      render :nothing => true
      return false
    elsif @workspace.update_attributes(params[:workspace])
      emit_activity(@workspace.thread,"edited workspace #{@workspace.title}") if @workspace.thread_type == "Puzzle"
      Push.send :command => "update workspace", :channel => @workspace.thread.chat_id, :workspace => @workspace.render
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
