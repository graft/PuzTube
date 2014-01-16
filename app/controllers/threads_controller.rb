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
end
