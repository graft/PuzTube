class TopicsController < ApplicationController
  # GET /topics
  # GET /topics.xml
  def index
    @topics = Topic.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic = Topic.find_by_name(params[:name])
    @chats = Chat.find(:all, :conditions => {:chat_id => @topic.chat_id}, :order => "created_at DESC", :limit => 10)
    @chatusers = Juggernaut.show_clients_for_channel(@topic.chat_id)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.xml
  def new
    @topic = Topic.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find_by_name(params[:name])
  end

  # POST /topics
  # POST /topics.xml
  def create
    @topic = Topic.new(params[:topic])

    respond_to do |format|
      if @topic.save
        flash[:notice] = 'Topic was successfully created.'
        format.html { redirect_to(topic_path(@topic.name)) }
        format.xml  { render :xml => @topic, :status => :created, :location => @topic }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = Topic.find_by_name(params[:name])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:notice] = 'Topic was successfully updated.'
        format.html { redirect_to(@topic) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    @topic = Topic.find_by_name(params[:name])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to(topics_url) }
      format.xml  { head :ok }
    end
  end
  
  def chat
    @topic = Topic.find(params[:id])
    text = params[:chat_input]
    user = current_or_anon_login
    channel = @topic.chat_id
    if (text =~ /\/([\w]*) /)
      channel = $1
      text.gsub!(/\/[\w]* /,'')
      user = "MAYHEM" if (channel == "all")
    end
    @chat = Chat.new( {
                       :user => user,
                       :text => text,
                       :chat_id => channel
                      } )
    if (@chat.save)
      # how do we render this?
      render :juggernaut => { :type => (channel == "all" ? :send_to_all : :send_to_channel ), :channel => channel } do |page|
        page << "jug_chat_update('<li>#{h @chat.dateformat} <b>#{h @chat.user}:</b> #{javascript_escape sanitize_text @chat.text }</li>');"
      end
    end
    render :nothing => true
  end
end