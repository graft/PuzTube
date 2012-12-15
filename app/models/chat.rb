class Chat < ActiveRecord::Base
	attr_accessible :user
  def timeformat
    created_at.getlocal.strftime("%H:%M")
  end
  
  def dateformat
    created_at.getlocal.strftime("%B %d, %Y")
  end
  
  def day
    created_at.getlocal.end_of_day
  end
end
