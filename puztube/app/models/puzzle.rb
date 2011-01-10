class Puzzle < ActiveRecord::Base
  belongs_to :round
  has_many :workspaces, :as => :thread
       
  def chat_id
    "PUZ"+id.to_s
  end

  def t_id
    "PZR"+id.to_s
  end
  
  def status_color
    case
    when status == "Needs Insight"
      "#9c6"
    when status == "Under Control"
      "#ffc"
    when status == "Solved"
      "#36c"
    when status == "Unimportant"
      "#f00"
    when status == "New"
      "#ff9"
    else
      "#fff"
    end
  end
end
