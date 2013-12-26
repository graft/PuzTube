class ThreadsController < ApplicationController
  before_filter :require_user
  layout "threads"

  class << self
    def thread_type val
      @thread_class = val
    end
    attr_reader :thread_class
  end

  def thread_class
    self.class.thread_class
  end

  def chat
    @thread = thread_class.find(params[:id])
    text = params[:chat_input]
    user = current_or_anon_login
    channel = @thread.chat_id
    send_chat(user,channel,text)

    render :nothing => true
  end
end
