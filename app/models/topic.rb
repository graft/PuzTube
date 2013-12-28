class Topic < ActiveRecord::Base
  include PuzzleThread
  has_many :workspaces, :as => :thread, :order => 'priority'
  validates_uniqueness_of :name
  
end
