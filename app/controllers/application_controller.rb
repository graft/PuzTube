# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include ApplicationHelper

  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  def current_user
    @current_user ||= (cookies[:user] ? User.find_by_login(cookies[:user]) : false)
  end

  def recent_broadcasts
    return Chat.find(:all, :conditions => { :chat_id => "all" }, :order => "created_at DESC", :limit => 2)  
  end

end
