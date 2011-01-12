class Puzzle < ActiveRecord::Base
  belongs_to :round
  has_many :workspaces, :as => :thread, :order => 'priority'
       
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
    when status == "Urgent"
      "#f6f"
    when status == "Solved"
      "#36c"
    when status == "Unimportant"
      "#666"
    when status == "New"
      "#ff9"
    when status == "Needs MIT-Local"
      "#cc9"
    else
      "#fff"
    end
  end

  def self.status_options
    [ "Urgent", "Needs Insight", "Needs MIT-Local", "New", "Under Control", "Solved", "Unimportant" ]
  end
end
