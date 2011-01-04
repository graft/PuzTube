class Chat < ActiveRecord::Base
  def dateformat
    created_at.strftime("%H:%M")
  end
end
