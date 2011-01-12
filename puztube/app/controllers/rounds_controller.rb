class RoundsController < ApplicationController
  # GET /rounds
  # GET /rounds.xml
  def index
    @rounds = Round.find(:all,:order => 'updated_at DESC')
    @sorting = (current_user&&current_user.options)?current_user.options[:sorting]:"status"
    @grouped = (current_user&&current_user.options)?current_user.options[:grouped]:false
    statord = { "Urgent"=>0,"Needs Insight"=>1,"Needs MIT-Local"=>2,"New"=>3,"Under Control"=>4,"Solved"=>5,"Unimportant"=>6 }
    if @grouped
      @rounds.each do |round|
        round.puzzles.sort!{ |p1,p2|
        if @sorting == "status"
          statord[p1.status] <=> statord[p2.status]
        elsif @sorting == "name"
          p1.name <=> p2.name
        else
          p1.created_at <=> p2.created_at
        end
      }
      end
    else
      @puzzles = Puzzle.find(:all).sort!{ |p1,p2|
        if @sorting == "status"
          statord[p1.status] <=> statord[p2.status]
        elsif @sorting == "name"
          p1.name <=> p2.name
        else
          p1.created_at <=> p2.created_at
        end
      }
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rounds }
    end
  end

  # GET /rounds/1
  # GET /rounds/1.xml
  def show
    @round = Round.find(params[:id])
    @sorting = (current_user&&current_user.options)?current_user.options[:sorting]:"status"

    render :partial => 'show', :locals => { :round => @round, :sorting => @sorting }
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
    @round.destroy
    render :nothing => true
  end
end
