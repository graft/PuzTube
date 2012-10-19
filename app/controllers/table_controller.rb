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
    @table.save
    render :nothing => true
  end
  
  def delete
    logger.info "Destroying"
    @table = Table.find(params[:id])
    @table.destroy
    render :nothing => true
  end
  
  def edit
    @table = Table.find(params[:id])
    render :partial => 'edit', :locals => { :table => @table, :yourtext => nil }
  end

  def show
    @table = Table.find(params[:id])
    render :partial => 'show', :locals => { :table => @table, :yourtext => nil, :update => true }
  end

  def update_cell
    # no need to be careful with this data
    @tablecell = TableCell.find(params[:id])
    @tablecell.contents = params[:text]
    @tablecell.save
    emit_activity(@tablecell.table.thread,"edited workspace #{@tablecell.table.title}") if @tablecell.table.thread_type == "Puzzle"
    render :nothing => true
  end

  def prioritize
    @table = Table.find(params[:id])
    return false if (params[:table][:priority] == @table.priority)
    render :nothing => true
  end

  def update
    @table = Table.find(params[:id])
    if params[:raw] && params[:useraw]
      update_from_raw(table,params[:raw])
    end
    
    if @table.update_attributes(params[:table])
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
    @table.save
    render :nothing => true
  end
end
