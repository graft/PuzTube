class PuzzlesController < ThreadsController
  thread_type Puzzle

  def show
    @puzzle = Puzzle.find(params[:id])
    @round = @puzzle.round
    @chats = Chat.find(:all, :conditions => {:chat_id => @puzzle.chat_id}, :order => "created_at DESC", :limit => 25)
  end
  
  def chat
    super.chat
    emit_activity(@thread, "spoke in chat")
  end

  def edit_row
    @puzzle = Puzzle.find(params[:puzzle][:id])
    broadcast_puzzle_edit(@puzzle,params[:puzzle])
    render :nothing => true
  end  
  
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
      if params[:c]
        render :partial => 'miniblock', :locals => { :puzzle => @puzzle }
      else
        render :partial => 'miniinfo', :locals => { :puzzle => @puzzle }
      end
    else
      render :partial => 'info', :locals => { :puzzle => @puzzle }
    end
  end

  def create
    @puzzle = Puzzle.new(params[:puzzle])

    if @puzzle.save
      redirect_to(@puzzle)
    else
      render :action => "new"
    end
  end

  def update
    @puzzle = Puzzle.find(params[:id])
    broadcast_puzzle_edit(@puzzle,params[:puzzle])
    render :nothing => true
  end

  def worker
    @puzzle = Puzzle.find(params[:id])
    
    emit_activity(@puzzle, "is working")
    render :nothing => true
  end

  def activities
    @puzzle = Puzzle.find(params[:id])
    render :json => Activity.where(:puzzle_id => @puzzle).all
  end

  def destroy
    @puzzle = Puzzle.find(params[:id])

    Push.send :command => "destroy puzzle", :channel => @puzzle.round.hunt.chat_id, :puzzle => @puzzle.t_id
    @puzzle.destroy
    render :nothing => true
  end

  private

  def broadcast_puzzle_edit(puzzle,params)
    params[:id] = nil if params[:id] # we don't need it any more
    if ((params[:answer] =~ /[A-Za-z]/ || params[:status] == "Solved") && puzzle.status != "Solved")
      params[:status] = "Solved"
      params[:priority] = "Low"
      broad = true
    else
      broad = false
    end
    if puzzle.update_attributes(params)
      Push.send :command => "update puzzle", :channel => puzzle.round.hunt.chat_id, :puzzle => puzzle.id, :table => puzzle.t_id
      Push.send :command => "update puzzle info", :channel => puzzle.chat_id, :puzzle => puzzle.id
      Push.send :command => "chat", :text => "<li>#{h Time.now.strftime("%H:%M")} <b>MAYHEM BROADCAST</b> <font style=#{ javascript_escape("'color: red;'")}>Puzzle #{h puzzle.name} in Round #{h javascript_escape puzzle.round.name} was solved with answer #{h javascript_escape puzzle.answer}</font></li>" if broad
    end
  end
end
