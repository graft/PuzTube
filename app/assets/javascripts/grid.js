grid_colors = { "!":"grid_black",
	"@":"grid_brown", "#":"grid_red",
	"$":"grid_orange", "%":"grid_yellow",
	"^":"grid_green", "&":"grid_blue",
	"*":"grid_purple" };

var GridCell = function(r,c,g,i) {
  var grid = g;
  var row = r;
  var col = c;
  var self = this;
  self.input = $(i);
  self.cell_up = function () {
    if (!row) return true;
    return grid.cells[row-1][col].focus();
  };
  self.cell_top = function () {
    return grid.cells[0][col].focus();
  };
  self.cell_down = function () {
    if (row+1 >= grid.rows) return true;
    return grid.cells[row+1][col].focus();
  };
  self.cell_bottom = function () {
    return grid.cells[grid.rows-1][col].focus();
  };
  self.cell_left = function () {
    if (!col) return true;
    return grid.cells[row][col-1].focus();
  };
  self.cell_leftmost = function () {
    return grid.cells[row][0].focus();
  };
  self.cell_right = function () {
    if (col+1 >= grid.cols) return true;
    return grid.cells[row][col+1].focus();
  };
  self.cell_rightmost = function () {
    return grid.cells[row][grid.cols-1].focus();
  };
  self.focus = function() {
    self.input.focus();
    self.input.select();
    return false;
  };
  self.click_handler = function(evt) {
    console.log("Processing click.");

		if (!evt.shiftKey) return false;
		var label = self.input.prev();
		var name = prompt("Label for this cell", label.html());
		if (name == null) return true;
		if (name.match(/[A-Z0-9]*/)) {
			// it is a valid label. Set it.
			var v = self.input.val() + ':' + name;
			self.input.addClass('updating');
			$.get('/workspace/update_cell', { grid: grid.gid, ws: grid.ws, row: row, col: col, text: v });
		}
		return true;
	};
  self.input.on('click', self.click_handler);
  var KEY = {
    ENTER: 13,
    DOWN: 40, UP: 38,
    LEFT: 37, RIGHT: 39,
    HOME: 36, END: 35,
    PAGE_UP: 33, PAGE_DOWN: 34
  };
  self.key_handler = function(evt) {
    if (evt.keyCode==KEY.ENTER || evt.keyCode==KEY.DOWN) return self.cell_down();
    else if (evt.keyCode == KEY.UP) return self.cell_up();
    else if (evt.keyCode == KEY.LEFT) return self.cell_left();
    else if (evt.keyCode == KEY.RIGHT) return self.cell_right();
    else if (evt.keyCode == KEY.HOME) return self.cell_leftmost();
    else if (evt.keyCode == KEY.END) return self.cell_rightmost();
    else if (evt.keyCode == KEY.PAGE_UP) return self.cell_top();
    else if (evt.keyCode == KEY.PAGE_DOWN) return self.cell_bottom();
    return true;
  };
  self.input.on('keypress',self.key_handler);
  self.change_handler = function(evt) {
		var v = self.input.val() + ':' + self.input.prev().html();
		self.input.addClass('updating');
		$.get('/workspace/update_cell', { grid: grid.gid, ws: grid.ws, row: row, col: col, text: v });
	};
  self.input.on('change',self.change_handler);
  self.update_txt = function(txt) {
    console.log("Updating cell "+row+","+col+" with: "+txt);
    self.input.removeClass('updating');
	  var a = txt.split(":");
	  for (var n in grid_colors) {
		  self.input.removeClass(grid_colors[n]);
	  }
    if (a[0].match(/^[\!\@\#\$\%\^\&\*]/)) self.input.addClass(grid_colors[a[0]]);
    if (a.length > 1) {
      self.input.prev().html( a[1] );
    }
  }

};

var Grid = function(r,c,gid,ws) {
  this.rows = r;
  this.cols = c;
  this.gid = gid;
  this.ws = ws;
  console.log("New Grid "+ws+"_"+gid);
  this.cells = [];

  for (var i = 0; i < this.rows; i++) {
    this.cells[i] = [];
  }
}

var grids = {};
console.log("Watching for grids.");
Grid.prepare = function(elt) {
  elt.find('[data-grid-id]').each(function() {
    // create a new Grid object.
    var self = $(this);
    var gid = self.data('grid-id');
    var ws = self.data('grid-ws');
    var rows = self.data('grid-rows');
    var cols = self.data('grid-cols');
    var grid = new Grid(rows,cols,gid,ws);
    grids[ ws + '_' + gid ] = grid;

    self.find('[data-grid-r]').each(function() {
      var r = $(this).data('grid-r');
      var c = $(this).data('grid-c');
      grid.cells[r][c] = new GridCell(r,c,grid,this);
      })
  });
}

$(function() {
    Grid.prepare($('body'));
});

