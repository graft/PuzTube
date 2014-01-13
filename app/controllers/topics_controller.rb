class TopicsController < ThreadsController
  thread_type Topic

  def index
    @topics = Topic.all
  end

  def show
    @topic = Topic.find_by_name!(params[:name])
    @chats = Chat.find(:all, :conditions => {:chat_id => @topic.chat_id}, 
                         :order => "created_at DESC", :limit => 35)
  end

  def get
    @topic = Topic.find(get_id params[:channel])
    render :json => @topic.to_json(:include => :workspaces)
  end

  def new
    @topic = Topic.new
  end

  def edit
    @topic = Topic.find_by_name(params[:name])
  end

  def create
    @topic = Topic.new(params[:topic])

    if @topic.save
      redirect_to(topic_path @topic.name)
    else
      render :action => "new"
    end
  end

  def update
    @topic = Topic.find_by_name(params[:name])

    if @topic.update_attributes(params[:topic])
      redirect_to(@topic)
    else
      render :action => "edit"
    end
  end

  def destroy
    @topic = Topic.find_by_name(params[:name])
    @topic.destroy

    redirect_to(topics_url)
  end
end
