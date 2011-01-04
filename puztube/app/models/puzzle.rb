class Puzzle < ActiveRecord::Base
  belongs_to :round
        
  def chat_id
    "PUZ"+id.to_s
  end

end
