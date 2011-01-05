class ConnectionsController < ApplicationController
  
  def subscribe
    if (params[:channels])
      params[:channels].each do |channel|
        render :juggernaut => { :type => :send_to_channel, :channel => channel } do |page|
          page << "subscribe_user('#{h params[:client_id]}');"
        end
      end
    end
    render :nothing => true
  end

  def unsubscribe
    if (params[:channels])
      params[:channels].each do |channel|
        render :juggernaut => { :type => :send_to_channel, :channel => channel } do |page|
          page << "unsubscribe_user('#{h params[:client_id]}');"
        end
      end
    end
    render :nothing => true
  end

end
