class RoundsController < ApplicationController
  before_filter :require_user
  def index
    @current_hunt = DataStore.find_by_key("current_hunt")
   
    if @current_hunt
      redirect_to hunt_path @current_hunt.value.to_i
    end
  end

  def create
    @round = Round.create(params[:round])
    @round.save
    Push.send :command => :add, :round => @round
    render :nothing => true
  end

  def show
    @round = Round.find(params[:id])
  end

  def edit
    @round = Round.find(params[:id])
    render :partial => 'edit', :locals => { :round => @round }
  end

  def update
    @round = Round.find(params[:id])
    @sorting = (current_user&&current_user.options)?current_user.options[:sorting]:"status"

     if @round.update_attributes(params[:round])
      logger.info "Rendered channel for #{@round.hunt.chat_id}"
      Push.send :command => :update, :round => @round.id, :channel => @round.hunt.chat_id, :table => @round.div_id
    end
    render :nothing => true
  end

  def destroy
    @round = Round.find(params[:id])
    
    Push.send :command => "remove", :round => @round.id, :channel => [ @round.hunt.chat_id, @round.chat_id ]
    @round.hidden = true
    @round.hunt_id = nil
    @round.save
    render :nothing => true
  end
end
