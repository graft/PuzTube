class Workspace < ActiveRecord::Base
  belongs_to :thread, :polymorphic => true
  has_many :assets
  attr_accessible :title, :editor, :content, :priority, :thread_id, :workspace_type, :thread_type


  def setup_type
    case workspace_type
    when "workspace_table"
      self.content = ([([""]*5).join("\t")]*5).join("\n")
    end
  end

  def simple_table
    content.split(/\n/).map.with_index do |r,i|
      r.split(/\t/,-1).map.with_index do |c,j|
        yield c,i,j
      end
    end
  end

  def render
    json = as_json(:include => :assets)

    case workspace_type
    when "workspace_table"
      if content
        table = simple_table do |c,i,j|
          { :contents => c, :row => i, :col => j }
        end
        json[:table_header] = table.shift
        json[:table_rows] = table
      end
    end
    json
  end

  def add_row
    table = simple_table{|c| c }
    cols = table.first.size
    table.push [ "" ] * cols
    make_content table
  end

  def add_col
    table = simple_table{|c| c }
    table.each do |t|
      t.push ""
    end
    make_content table
  end

  def update_cell row, col, contents
    table = simple_table{|c| c }
    row = row.to_i
    col = col.to_i
    if row < table.size && col < table.first.size
      table[row][col] = contents
    end
    make_content table
  end

  def make_content t
    self.content = t.map{|r| r.join("\t")}.join("\n")
  end
end
