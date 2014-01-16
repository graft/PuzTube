class PuzzlesController < ThreadsController
  thread_type Puzzle
  before_filter :require_user

  def show
    @puzzle = Puzzle.find(params[:id])
    @round = @puzzle.round
    @chats = Chat.find(:all, :conditions => {:chat_id => @puzzle.chat_id}, :order => "created_at DESC", :limit => 25)
  end
  
  def chat
    super.chat
    emit_activity(@thread, "spoke in chat")
  end

  def get
    @puzzle = Puzzle.find(get_id params[:channel])
    if @puzzle.meta
      json = @puzzle.as_json(:include => {:round => {:include => :puzzles}})
      json["workspaces"] = @puzzle.workspaces.map{|w| w.render}
      render :json => json
    else
      json = @puzzle.as_json(:include => :round)
      json["workspaces"] = @puzzle.workspaces.map{|w| w.render}
      render :json => json
    end
  end

  def wrong
    @puzzle = Puzzle.find(params[:id])
    guess = @puzzle.guess
    if @puzzle.update_attributes(:guess => nil, :wrong_answer => @puzzle.wrong_guess)
      Push.send :command => 'update puzzle', :puzzle => @puzzle, :channel => @puzzle.update_channels
      send_chat :OPERATOR, @puzzle.chat_id, "#{guess} was incorrect"
    end
    render :nothing => true
  end

  def reject
    @puzzle = Puzzle.find(params[:id])
    guess = @puzzle.guess
    if @puzzle.update_attributes(:guess => nil)
      Push.send :command => 'update puzzle', :puzzle => @puzzle, :channel => @puzzle.update_channels
      send_chat :OPERATOR, @puzzle.chat_id, "#{guess} was rejected"
    end
    render :nothing => true
  end

  def solve
    @puzzle = Puzzle.find(params[:id])
    guess = @puzzle.guess
    if @puzzle.update_attributes(:guess => nil, :answer => guess, :status => :Solved)
      Push.send :command => 'update puzzle', :puzzle => @puzzle, :channel => @puzzle.update_channels
      Push.send :command => "chat", :user => :BROADCAST, :text => "Puzzle #{@puzzle.name} in Round #{@puzzle.round.name} was solved with answer #{@puzzle.answer}"
    end
    render :nothing => true
  end

  def workspaces
    @puzzle = Puzzle.find(params[:id], :include => :workspaces)
    render :json => @puzzle.workspaces
  end

  def edit
    @puzzle = Puzzle.find(params[:id])
    if @puzzle.update_attributes(params[:puzzle])
      Push.send :command => 'update puzzle', :puzzle => @puzzle, :channel => @puzzle.update_channels
    end
    render :nothing => true
  end
  
  def create
    params[:puzzle].update( :priority => "Normal", :status => "New")
    @puzzle = Puzzle.create(params[:puzzle])
    if @puzzle.save
      Push.send :command => "new puzzle", :puzzle => @puzzle, :channel => @puzzle.round.hunt.chat_id
    end
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

    Push.send :command => "destroy puzzle", :channel => @puzzle.update_channels, :puzzle => @puzzle
    @puzzle.round_id = nil
    @puzzle.save
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
    end
  end
end
