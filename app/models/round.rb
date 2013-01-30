class Round < ActiveRecord::Base
  has_many :puzzles
  has_many :workspaces, :as => :thread, :order => 'priority'
  belongs_to :hunt
  attr_accessible :name, :hunt_id, :url, :hint, :captain, :answer

  SORTING = { 'priority' => :priority_order, 'status' => :status_order, 'creation' => :created_at, 'name' => :name }
  PRIORITY_OPTIONS = { "High" => 0, "Normal" => 1, "Low" => 2 }

  def chat_id
    "round-#{id}"
  end

  def div_id
    "rnd-#{id}"
  end
  def t_id
    "rnt-#{id}"
  end
  def puzzle_table_id
    "rpt-#{id}"
  end
  def priority_color
    case priority
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
    priority.blank? ? 1: Round::PRIORITY_OPTIONS[priority]
  end
end
