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
end
