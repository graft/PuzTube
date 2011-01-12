class Workspace < ActiveRecord::Base
  belongs_to :thread, :polymorphic => true
  has_many :assets

  def div_id
    "WS" + id.to_s
  end
  
  def form_id
    "WF" + id.to_s
  end

  def self.priorities
    ["High", "Normal","Useless"]
  end
end
