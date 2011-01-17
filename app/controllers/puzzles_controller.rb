class PuzzlesController < ApplicationController
  include PuzzlesHelper
  # GET /puzzles
  # GET /puzzles.xml
  def index
    @puzzles = Puzzle.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @puzzles }
    end
  end

  # GET /puzzles/1
  # GET /puzzles/1.xml
  def show
    @puzzle = Puzzle.find(params[:id])
    @broadcasts = recent_broadcasts
    @round = Round.find(@puzzle.round_id)
    @chats = Chat.find(:all, :conditions => {:chat_id => @puzzle.chat_id}, :order => "created_at DESC", :limit => 10)
    @chatusers = Juggernaut.show_clients_for_channel(@puzzle.chat_id)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @puzzle }
    end
  end
  
  # GET /puzzles/new
  # GET /puzzles/new.xml
  def new
    @puzzle = Puzzle.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @puzzle }
    end
  end

  def chat
    @puzzle = Puzzle.find(params[:id])
    text = params[:chat_input]
    user = current_or_anon_login
    set_worker(@puzzle,current_user) if current_user
    channel = @puzzle.chat_id
    send_chat(user,channel,text)
    render :nothing => true
  end

  def edit_row
    @puzzle = Puzzle.find(params[:puzzle][:id])
    broadcast_puzzle_edit(@puzzle,params[:puzzle])
    render :nothing => true
  end  
  
  # GET /puzzles/1/edit
  def edit
    @puzzle = Puzzle.find(params[:id])
    @round = Round.find(@puzzle.round_id)
    if params[:type] == 'mini'
      render :partial => 'miniedit'
    else
      render :partial => 'edit'
    end
  end
  
  def info
    @puzzle = Puzzle.find(params[:id])
    @round = Round.find(@puzzle.round_id)
    if params[:type] == 'mini'
      render :partial => 'miniinfo', :locals => { :puzzle => @puzzle }
    else
      render :partial => 'info', :locals => { :puzzle => @puzzle }
    end
  end

  # POST /puzzles
  # POST /puzzles.xml
  def create
    @puzzle = Puzzle.new(params[:puzzle])

    respond_to do |format|
      if @puzzle.save
        flash[:notice] = 'Puzzle was successfully created.'
        format.html { redirect_to(@puzzle) }
        format.xml  { render :xml => @puzzle, :status => :created, :location => @puzzle }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @puzzle.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /puzzles/1
  # PUT /puzzles/1.xml
  def update
    @puzzle = Puzzle.find(params[:id])
    broadcast_puzzle_edit(@puzzle,params[:puzzle])
    render :nothing => true
  end

  def worker
    @puzzle = Puzzle.find(params[:id])
    set_worker(@puzzle,current_user) if current_user
    broadcast_puzzle_edit(@puzzle,{})
    render :nothing => true
  end

  # DELETE /puzzles/1
  # DELETE /puzzles/1.xml
  def destroy
    @puzzle = Puzzle.find(params[:id])

    render :juggernaut => { :type => :send_to_channel, :channel => "ROUNDS" } do |page|
      page << "$('#{@puzzle.t_id}').remove();"
    end
    
    @puzzle.destroy
    render :nothing => true
  end
end
