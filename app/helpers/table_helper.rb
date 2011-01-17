module TableHelper
  def create_table(table,rows,cols)
    table.rows = []
    table.cols = cols
    rows.times do |j|
      add_row(table)
    end
  end

  def add_row(table)
    row = []
    table.cols.times do |j|
      cell = table.table_cells.build
      cell.save
      row.push(cell.id)
    end
    table.rows.push(row)
  end

  def add_column(table)
    table.rows.each do |row|
      cell = table.table_cells.build
      cell.save
      row.push(cell.id)
    end
    table.cols += 1
  end

  def remove_column(table,ind)
    return if table.cols <= ind || ind < 0
    col = []
    table.rows.each do |row|
      col.push( row.slice!(ind) )
    end
    table.cols -= 1
    return col
  end
  
  def remove_row(table,ind)
    return if table.rows.length <= ind || ind < 0
    return table.rows.slice!(ind)
  end

  def update_from_raw(table,rawtext)
    rows = rawtext.split(/\n/)
    max = 0
    rows.each_index do |i|
      rows[i] = rows[i].split(/\,/)
      max = rows[i].length if max < rows[i].length
    end
    until table.cols >= max
      add_column(table)
    end
    until table.rows.length >= rows.length
      add_row(table)
    end
    rows.each_index do |i|
      rows[i].each_with_index do |j|
        table.getcell(table.rows[i][j]).contents = rows[i][j]
      end
    end
  end

  def raw_text(table)
    table.rows.map{|row|
      row.map{|cell|
        table.getcell(cell).contents
      }.join(",")
    }.join("\n")
  end

  def insert_column(table,col,ind)
    return if table.cols <= ind || ind < 0
    table.rows.each_index do |j|
      table.rows[j].insert(ind,col[j])
    end
  end

  def insert_row(table,row,ind)
    return if table.rows.length <= ind || ind < 0
    table.rows.insert(ind,row)
  end

  def move_row(table,old,new)
    return if old == new || table.rows.length <= old || table.rows.length <= new || old < 0 || new < 0
    row = remove_row(table,old)
    if (old > new)
      insert_row(table,new)
    else
      insert_row(table,new-1)
    end
  end

  def move_column(table,old,new)
    return if old == new || table.cols <= old || table.cols <= new || old < 0 || new < 0
    col = remove_column(table,old)
    if (old > new)
      insert_column(table,new)
    else
      insert_column(table,new-1)
    end
  end
end
