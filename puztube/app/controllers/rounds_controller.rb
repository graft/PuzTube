class RoundsController < ApplicationController
  # GET /rounds
  # GET /rounds.xml
  def index
    @rounds = Round.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rounds }
    end
  end

  # GET /rounds/1
  # GET /rounds/1.xml
  def show
    @round = Round.find(params[:id])

    render :partial => 'show', :locals => { :round => @round }
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
    
    if @puzzle.save
      text = render_to_string :partial => 'puzzles/miniblock', :locals => { :puzzle => @puzzle }
      render :juggernaut => { :type => :send_to_channel, :channel => "ROUNDS" } do |page|
        page << "$('RPT#{@round.id}').insert({bottom: '#{javascript_escape text}'});"
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

     if @round.update_attributes(params[:round])
      flash[:notice] = 'Round was successfully updated.'
        # DON'T update here - use juggernaut to send the request. You need the chat id!
      txt = render_to_string :partial => "show", :locals => { :round => @round }
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
    @round.destroy
    render :nothing => true
  end
end
