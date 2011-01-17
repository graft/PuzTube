class Chat < ActiveRecord::Base
  def dateformat
    created_at.getlocal.strftime("%H:%M")
  end
end
