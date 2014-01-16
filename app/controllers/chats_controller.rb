class ChatsController < ApplicationController
  def index
    @chats = Chat.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @chats }
    end
  end

  def broadcasts
    @broadcasts = Chat.find(:all, :conditions => { :chat_id => "all" }, :order => "created_at DESC")
  end

  def update
    @chat = Chat.find(params[:id])

    if @chat.update_attributes(params[:chat])
      redirect_to(broadcasts_path)
    else
      render :action => "edit"
    end
  end
 
  def post
    begin
      text = params[:chat_input]
      user = current_or_anon_login
      channel = params[:channel]
      @chat = Chat.new(:user => user,
                       :text => sanitize_text(text),
                       :chat_id => params[:channel])
      if @chat.save
        logger.info "Pushing chat request to channel #{channel}"
        Push.send :command => "chat", :channel => channel, :chat => @chat
      end
      render :nothing => true
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
  
  def window
    @chats = Chat.find(:all, :conditions => { :chat_id => params[:channel] }, :order => "created_at DESC", :limit => 35)
  end

  def recent
    render :json => Chat.find(:all, :conditions => { :chat_id => params[:channel] }, :order => "created_at DESC", :limit => 35).reverse
  end

  # DELETE /chats/1
  # DELETE /chats/1.xml
  def destroy
    @chat = Chat.find(params[:id])
    @chat.destroy
    render :js => 'window.location.reload()'
  end
end
