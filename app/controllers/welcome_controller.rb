class WelcomeController < ApplicationController
	layout 'general'

	def index
	end
        
        def login
          if (params[:user][:login] && user = User.find_by_login(params[:user][:login]))
            cookies[:user] = user.login
            render :js => 'window.location.reload()'
          end
        end
        
        def logout
          cookies[:user] = nil
          render :js => 'window.location.reload()'
        end
        
        def test
          render :juggernaut => { :type => :send_to_client_on_channel, :client_id => params[:user], :channel => params[:channel] } do |page|
            page << "connectionActive('#{params[:channel]}','#{params[:user]}')"
          end
          render :js => "connectionTimer()"
        end
end
