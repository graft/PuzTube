class Workspace < ActiveRecord::Base
  belongs_to :thread, :polymorphic => true
  
  def div_id
    "WS" + id.to_s
  end
  
  def form_id
    "WF" + id.to_s
  end
end
