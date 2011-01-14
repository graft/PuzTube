class TableCell < ActiveRecord::Base
  belongs_to :table
  def t_id
    "TC"+id.to_s
  end
end
