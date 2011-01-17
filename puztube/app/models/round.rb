class Round < ActiveRecord::Base
  has_many :puzzles
  has_many :workspaces, :as => :thread, :order => 'priority'

  def chat_id
    "RND"+id.to_s
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
    Round.priority_options.index(priority) || 0
  end

  def self.priority_options
    [ "High", "Normal", "Low" ]
  end

end
