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
    begin
      thread_class = Kernel.const_get params[:thread]
      raise "#{thread_class} is not a thread" unless thread_class.is_thread?
      id = params[:channel].scan(/^\w+-([0-9]+)/).flatten.first
      @thread = thread_class.find(id)
      text = params[:chat_input]
      user = current_or_anon_login
      channel = @thread.chat_id
      send_chat(user,channel,text)
    rescue Exception => e
      logger.info "#{e.message}"
    ensure
      render :nothing => true
    end
  end
end
