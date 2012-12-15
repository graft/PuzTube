# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#
require 'authenticated_system.rb'

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
  
  def require_user
    unless current_user
      flash[:notice] = "You must be logged in to access this page"
      redirect_to login_path
      return false
    end
  end
end
