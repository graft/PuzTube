class Activity < ActiveRecord::Base
  belongs_to :hunt
  belongs_to :user
  belongs_to :puzzle
  
  def dateformat
    created_at.getlocal.strftime("%m/%d/%y %H:%M")
  end
end
