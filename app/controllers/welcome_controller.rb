class WelcomeController < ApplicationController
  before_filter :require_user, :except => :login
	layout 'general'

	def index
    # okay, now you use current_hunt to get the thing.
	end
      
  def login
    if (params[:user][:login] && user = User.find_by_login(params[:user][:login]))
      cookies[:user] = { :value => user.login, :expires => 1.month.from_now }
      user.touch
      redirect_to root_url
    end
  end
        
  def logout
    cookies[:user] = nil
    render :js => 'window.location.reload()'
  end
end
