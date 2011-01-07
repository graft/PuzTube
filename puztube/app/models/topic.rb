class Topic < ActiveRecord::Base
  validates_uniqueness_of :name
  has_many :workspaces, :as => :thread
  
  def chat_id
    "TOP"+id.to_s
  end
end
