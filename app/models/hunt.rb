class Hunt < ActiveRecord::Base
	has_many :rounds
  has_many :puzzles, :through => :rounds

  
  
end
