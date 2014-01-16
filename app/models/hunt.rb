class Hunt < ActiveRecord::Base
	has_many :rounds
  has_many :puzzles, :through => :rounds
  has_many :activities
  attr_accessible :name, :url, :captain, :editor, :created_at

  def chat_id
    "hunt-#{id}"
  end  

  
end
