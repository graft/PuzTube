class RoundsController < ThreadsController
  thread_type Round
  before_filter :require_user

  def index
    @current_hunt = DataStore.find_by_key("current_hunt")
   
    if @current_hunt
      redirect_to hunt_path @current_hunt.value.to_i
    end
  end

  def create
    @round = Round.create(params[:round])
    if @round.save
      Push.send :command => "new round", :round => @round, :channel => @round.hunt.chat_id
    end
    render :nothing => true
  end

  def show
    @round = Round.find(params[:id])
  end

  def get
    @round = Round.find(get_id params[:channel])
    json = @round.as_json(:include => :puzzles)
    json["workspaces"] = @round.workspaces.map{|w| w.render}
    render :json => json
  end

  def edit
    @round = Round.find(params[:id])
    if @round.update_attributes(params[:round])
      Push.send :command => 'update round', :round => @round, :channel => @round.hunt.chat_id
    end
    render :nothing => true
  end

  def destroy
    @round = Round.find(params[:id])
    
    Push.send :command => "destroy round", :round => @round, :channel => @round.hunt.chat_id
    @round.hidden = true
    @round.hunt_id = nil
    @round.save
    render :nothing => true
  end
end
