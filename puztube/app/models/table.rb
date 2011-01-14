class Table < ActiveRecord::Base
  belongs_to :thread, :polymorphic => true
  has_many :table_cells

  def div_id
    "TB" + id.to_s
  end

  def form_id
    "TF" + id.to_s
  end

  def self.priorities
    ["High", "Normal","Useless"]
  end

end
