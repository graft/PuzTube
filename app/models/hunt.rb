class Hunt < ActiveRecord::Base
	has_many :rounds
  has_many :puzzles, :through => :rounds
  has_many :activities

  def chat_id
    "hunt-#{id}"
  end  
  
end
