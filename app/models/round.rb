class Round < ActiveRecord::Base
  has_many :puzzles
  has_many :workspaces, :as => :thread, :order => 'priority'
  belongs_to :hunt

  SORTING = { 'priority' => :priority_order, 'status' => :status_order, 'creation' => :created_at, 'name' => :name }
  PRIORITY_OPTIONS = { "High" => 0, "Normal" => 1, "Low" => 2 }

  def chat_id
    "RND"+id.to_s
  end

  def div_id
    "ROUND#{id}"
  end
  def t_id
    "RNT"+id.to_s
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
