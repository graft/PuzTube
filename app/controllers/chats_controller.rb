class ChatsController < ApplicationController
  # GET /chats
  # GET /chats.xml
  def index
    @chats = Chat.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @chats }
    end
  end

  # GET /chats/1
  # GET /chats/1.xml
  def show
    @chat = Chat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @chat }
    end
  end

  # GET /chats/new
  # GET /chats/new.xml
  def new
    @chat = Chat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @chat }
    end
  end

  # GET /chats/1/edit
  def edit
    @chat = Chat.find(params[:id])
  end

  # POST /chats
  # POST /chats.xml
  def create
    @chat = Chat.new(params[:chat])

    respond_to do |format|
      if @chat.save
        format.html { redirect_to(@chat) }
        format.xml  { render :xml => @chat, :status => :created, :location => @chat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @chat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /chats/1
  # PUT /chats/1.xml
  def update
    @chat = Chat.find(params[:id])

    respond_to do |format|
      if @chat.update_attributes(params[:chat])
        format.html { redirect_to(@chat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @chat.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def log
    @chats = Chat.find(:all, :conditions => [ "chat_id = ?",params[:channel]])
    if (params[:type] == "Puzzle")
      @thread = Puzzle.find(params[:thread])
    else
      @thread = Topic.find(params[:thread])
    end
  end

  # DELETE /chats/1
  # DELETE /chats/1.xml
  def destroy
    @chat = Chat.find(params[:id])
    @chat.destroy

    respond_to do |format|
      format.html { redirect_to(chats_url) }
      format.xml  { head :ok }
    end
  end
end
