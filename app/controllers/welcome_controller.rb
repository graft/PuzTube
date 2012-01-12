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
        
  def test
    chatusers =  Juggernaut.show_clients_for_channel(params[:channel]);
    render :juggernaut => { :type => :send_to_client_on_channel, :client_id => params[:user], :channel => params[:channel] } do |page|
      page << "connectionActive([#{chatusers.map{|c| "'#{c['client_id']}'"}.join(",")}]);"
    end
    render :js => "connectionTimer();"
  end
end
