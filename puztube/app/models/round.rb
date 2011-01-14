class Round < ActiveRecord::Base
  has_many :puzzles
  has_many :workspaces, :as => :thread, :order => 'priority'

  def chat_id
    "RND"+id.to_s
  end

  def t_id
    "RNT"+id.to_s
  end

end
