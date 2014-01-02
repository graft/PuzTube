class RoundsController < ApplicationController
  before_filter :require_user
  def index
    @current_hunt = DataStore.find_by_key("current_hunt")
   
    if @current_hunt
      redirect_to hunt_path @current_hunt.value.to_i
    end
  end

  def list
    hunt = params[:hunt].scan(/hunt-([0-9]+)/).flatten.first
    json = Round.where(:hunt_id => hunt)
              .all(:include => :puzzles)
              .map{ |r| r.as_json(:include => :puzzles) }
    render :json => json
  end

  def info
    @round = Round.find(params[:id])
    @sorting = (current_user&&current_user.options)?current_user.options[:sorting]:"status"
    @grouped = (current_user&&current_user.options)?current_user.options[:grouped]:false
    sorter = Proc.new { |p1,p2|
        if @sorting == "status"
          p1.status_order <=> p2.status_order
        elsif @sorting == "priority"
          p1.priority_order <=> p2.priority_order
        elsif @sorting == "name"
          p1.name <=> p2.name
        else
          p1.created_at <=> p2.created_at
        end
      }
    @round.puzzles.sort! &sorter
    if params[:c]
      render :partial => 'round', :locals => { :round => @round }
    else
      render :partial => 'show', :locals => { :round => @round }
    end
  end

  def show
    @round = Round.find(params[:id])
    @chats = Chat.find(:all, :conditions => {:chat_id => @round.chat_id}, :order => "created_at DESC", :limit => 10)
  end

  def create_puzzle
    @round = Round.find(params[:id])
    @puzzle = @round.puzzles.build
    @puzzle.name = "New Puzzle"
    @puzzle.status = "New"
    @puzzle.priority = "Normal"
    
    if @puzzle.save
      Push.send :command => "new puzzle", :channel => @round.hunt.chat_id, :puzzle => @puzzle.id, :table => @round.puzzle_table_id
    end
    render :nothing => true
  end

  def edit
    @round = Round.find(params[:id])
    render :partial => 'edit', :locals => { :round => @round }
  end

  def create
    @round = Round.new(params[:round])

    if @round.save
      redirect_to(@round)
    else
      render :action => "new"
    end
  end

  def update
    @round = Round.find(params[:id])
    @sorting = (current_user&&current_user.options)?current_user.options[:sorting]:"status"

     if @round.update_attributes(params[:round])
      logger.info "Rendered channel for #{@round.hunt.chat_id}"
      Push.send :command => "update round", :round => @round.id, :channel => @round.hunt.chat_id, :table => @round.div_id
    end
    render :nothing => true
  end

  def destroy
    @round = Round.find(params[:id])
    
    Push.send :command => "destroy round", :round => @round.div_id, :channel => @round.hunt.chat_id
    @round.hidden = true
    @round.hunt_id = nil
    @round.save
    render :nothing => true
  end
end
