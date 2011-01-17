class Table < ActiveRecord::Base
  belongs_to :thread, :polymorphic => true
  serialize :rows, Array
  has_many :table_cells

  def div_id
    "TB" + id.to_s
  end

  def t_id
    "TT" + id.to_s
  end

  def form_id
    "TF" + id.to_s
  end

  def self.priorities
    ["High", "Normal","Useless"]
  end

  def getcell(cell_id)
    # find the cell_id of the appropriate cell
    table_cells.detect { |cell| cell.id == cell_id }
  end

  # Okay, a puzzle table. hm. Well, basically it consists of a bunch of rows and columns, each of which
  # contain a piece of text. That is all. Plus there is a sort order - column and ascending/descending.
  # everything else is defined as appropriate.
  # Most of the time people will be editing a CELL - and you don't want idiots overwriting the wrong cell because
  # their page state is in the wrong situation. So keep a list of cells:
end
