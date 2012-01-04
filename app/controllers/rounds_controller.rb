class RoundsController < ApplicationController
  before_filter :require_user
  # GET /rounds
  # GET /rounds.xml
  def index
    @current_hunt = DataStore.find_by_key("current_hunt")
   
    respond_to do |format|
      if !@current_hunt.nil?
        format.html { redirect_to hunt_path(@current_hunt.value.to_i) }
      else
        format.html # index.html.erb
      end
      format.xml  { render :xml => @rounds }
    end
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
    render :partial => 'show', :locals => { :round => @round }
  end
  # GET /rounds/1
  # GET /rounds/1.xml
  def show
    @round = Round.find(params[:id])
    @broadcasts = recent_broadcasts
    @chats = Chat.find(:all, :conditions => {:chat_id => @round.chat_id}, :order => "created_at DESC", :limit => 10)
    @chatusers = Juggernaut.show_clients_for_channel(@round.chat_id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rounds }
    end
  end

  # GET /rounds/new
  # GET /rounds/new.xml
  def new
    @round = Round.new
    @round.name = "New Round"
    
    if @round.save
      text = render_to_string :partial => 'round', :locals => { :round => @round}
      # again, use juggernaut to do this.
      render :juggernaut => { :type => :send_to_channel, :channel => "ROUNDS" } do |page|
        page << "$('roundstable').insert({bottom: '#{javascript_escape text}'});"
      end
    else
      render :nothing => true
    end
  end
  
  def new_puzzle
    @round = Round.find(params[:id])
    @puzzle = @round.puzzles.build
  end

  def create_puzzle
    @round = Round.find(params[:id])
    @puzzle = @round.puzzles.build
    @puzzle.name = "New Puzzle"
    @puzzle.status = "New"
    @puzzle.priority = "Normal"
    
    if @puzzle.save
      text = render_to_string :partial => 'puzzles/miniblock', :locals => { :puzzle => @puzzle }
      render :juggernaut => { :type => :send_to_channel, :channel => "ROUNDS" } do |page|
        page << "add_puzzle('RPT#{@round.id}','#{javascript_escape text}');"
      end
    end
    render :nothing => true
  end
  # GET /rounds/1/edit
  def edit
    @round = Round.find(params[:id])
    
    render :partial => 'edit', :locals => { :round => @round }
  end

  # POST /rounds
  # POST /rounds.xml
  def create
    @round = Round.new(params[:round])

    respond_to do |format|
      if @round.save
        flash[:notice] = 'Round was successfully created.'
        format.html { redirect_to(@round) }
        format.xml  { render :xml => @round, :status => :created, :location => @round }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @round.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rounds/1
  # PUT /rounds/1.xml
  def update
    @round = Round.find(params[:id])
    @sorting = (current_user&&current_user.options)?current_user.options[:sorting]:"status"

     if @round.update_attributes(params[:round])
      flash[:notice] = 'Round was successfully updated.'
        # DON'T update here - use juggernaut to send the request. You need the chat id!
      txt = render_to_string :partial => "show", :locals => { :round => @round, :sorting => @sorting  }
      render :juggernaut => { :type => :send_to_channel, :channel => "ROUNDS" } do |page|
        page << "$('ROUND#{@round.id}').update('#{javascript_escape txt}');"
      end
    end
    render :nothing => true
  end

  # DELETE /rounds/1
  # DELETE /rounds/1.xml
  def destroy
    @round = Round.find(params[:id])
    
    render :juggernaut => { :type => :send_to_channel, :channel => "ROUNDS" } do |page|
      page << "$('ROUND#{@round.id}').remove();"
    end
    @round.hidden = true
    @round.save
    render :nothing => true
  end
end
