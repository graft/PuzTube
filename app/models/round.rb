class Round < ActiveRecord::Base
  include PuzzleThread
  has_many :puzzles
  belongs_to :hunt
  has_many :workspaces, :as => :thread, :order => 'priority'
  attr_accessible :name, :hunt_id, :url, :hint, :captain, :answer, :priority

  def update_channels
    [ chat_id, hunt.chat_id ]
  end

  SORTING = { 'priority' => :priority_order, 'status' => :status_order, 'creation' => :created_at, 'name' => :name }
  PRIORITY_OPTIONS = { "High" => 0, "Normal" => 1, "Low" => 2 }

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
