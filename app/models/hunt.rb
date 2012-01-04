class Hunt < ActiveRecord::Base
	has_many :rounds
  has_many :puzzles, :through => :rounds

  def chat_id
    "HUNT"+id.to_s
  end  
  
end
