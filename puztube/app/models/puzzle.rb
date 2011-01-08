class Puzzle < ActiveRecord::Base
  belongs_to :round
  has_many :workspaces, :as => :thread
       
  def chat_id
    "PUZ"+id.to_s
  end

  def t_id
    "PZR"+id.to_s
  end
end
