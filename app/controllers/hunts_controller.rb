class HuntsController < ApplicationController
  # GET /hunts
  # GET /hunts.xml
  def index
    @hunts = Hunt.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @hunts }
    end
  end

  # GET /hunts/1
  # GET /hunts/1.xml
  def show
    @hunt = Hunt.find(params[:id])
    
    @sorting = current_user.options[:sorting]
    sort_key = Round::SORTING[@sorting]
    @grouped = current_user.options[:grouped]
    
    if @grouped
      @hunt.rounds.sort! do |r1,r2|
        r1.priority_order <=> r2.priority_order
      end
      @hunt.rounds.each do |round|
        round.puzzles.sort! {|r1,r2| r1.send(sort_key) <=> r2.send(sort_key)}
      end
    else
      @hunt.puzzles.sort! {|r1,r2| r1.send(sort_key) <=> r2.send(sort_key)}
    end


    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @hunt }
    end
  end

  # GET /hunts/new
  # GET /hunts/new.xml
  def new
    @hunt = Hunt.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @hunt }
    end
  end
  
  def new_round
    @hunt = Hunt.find(params[:id])
    @round = @hunt.rounds.build
    @round.name = "New Round"

    
    if @round.save
      text = render_to_string :partial => 'rounds/round', :locals => { :round => @round}
      logger.info "Rendering new round, channel #{@hunt.chat_id}."
      Push.send :command => "new round", :channel => @hunt.chat_id, :round => @round.id
    end
    render :nothing => true
  end

  def stats
    @hunt = Hunt.find(params[:id])
    render :partial => "solving", :locals => { :hunt => @hunt, :shown => true }
  end
  # GET /hunts/1/edit
  def edit
    @hunt = Hunt.find(params[:id])
  end

  # POST /hunts
  # POST /hunts.xml
  def create
    @hunt = Hunt.new(params[:hunt])

    respond_to do |format|
      if @hunt.save
        format.html { redirect_to(@hunt, :notice => 'Hunt was successfully created.') }
        format.xml  { render :xml => @hunt, :status => :created, :location => @hunt }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @hunt.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /hunts/1
  # PUT /hunts/1.xml
  def update
    @hunt = Hunt.find(params[:id])
    
    if (params[:make_current])
      d = DataStore.find_or_create_by_key("current_hunt")
      d.value = @hunt.id
      d.save
    end

    respond_to do |format|
      if @hunt.update_attributes(params[:hunt])
        format.html { redirect_to(@hunt, :notice => 'Hunt was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @hunt.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /hunts/1
  # DELETE /hunts/1.xml
  def destroy
    @hunt = Hunt.find(params[:id])
    @hunt.destroy

    respond_to do |format|
      format.html { redirect_to(hunts_url) }
      format.xml  { head :ok }
    end
  end
end
