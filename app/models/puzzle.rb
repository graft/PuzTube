class Puzzle < ActiveRecord::Base
  include PuzzleThread
  belongs_to :round
  has_many :tables, :as => :thread, :order => 'priority'
  has_many :users
  has_many :activities
  has_many :workspaces, :as => :thread, :order => 'priority'
  attr_accessible :name, :url, :hint, :captain, :meta, :answer, :status, :priority, :round_id, :wrong_answer, :guess

  def update_channels
    [ chat_id, round.chat_id, round.hunt.chat_id ]
  end

  def wrong_guess
    ((wrong_answer || "").split(" ") + [ guess ]).join(" ")
  end

  def status_color
    case status
    when "Needs Insight"
      "#9c6"
    when "Under Control"
      "#ffc"
    when "Solved"
      "#36c"
    when "Unimportant"
      "#666"
    when "New"
      "#ff9"
    when "Needs MIT-Local"
      "#cc9"
    else
      "#fff"
    end
  end

  def status_order
    Puzzle.status_options.index(status) || 0
  end

  def self.status_options
    [ "Needs Insight", "Needs MIT-Local", "Needs Research", "New", "Under Control", "Solved", "Unimportant" ]
  end

  def priority_color
    case priority
    when "Urgent"
      "#f6f"
    when "High"
      "#f60"
    when "Normal"
      "#69f"
    when "Low"
      "#666"
    else
      "#fff"
    end
  end
  
  def priority_order
    Puzzle.priority_options.index(priority) || 0
  end

  def self.priority_options
    [ "Urgent", "High", "Normal", "Low" ]
  end
end
