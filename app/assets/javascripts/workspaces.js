//= require grid

String.prototype.reverse = function() {
    var s = "";
    var i = this.length;
    while (i>0) {
        s += this.substring(i-1,i);
        i--;
    }
    return s;
}
String.prototype.replaceAt = function(index, c) {
	  return this.substr(0, index) + c + this.substr(index+c.length);
}

function insert_asset(divid,txt) {
  if ($(divid+'.assets')) {
    $(divid+'.assets').insert({bottom: txt});
  }
}

function delete_asset(divid,assetid) {
  if ($(divid+'.asset'+assetid)) {
    $(divid+'.asset'+assetid).remove()
  }
}

function sortWorkspaces() {
  console.log("Sorting workspaces.");
  workspaces = $('div.workspace');
  high = []
  normal = []
  useless = []
  other = []
  workspaces.each(function(i,ws) {
    fd = $(ws.children[0]);
    if (fd) {
      if (fd.hasClass('priority_High')) high.push(ws);
      else if (fd.hasClass('priority_Normal')) normal.push(ws);
      else if (fd.hasClass('priority_Useless')) useless.push(ws);
      else other.push(ws);
    }
  });
  if ($('#comments')) {
    $('#comments').html('');
    $(high).each(function(i,ws) { $('#comments').append(ws); });
    $(normal).each(function(i,ws) { $('#comments').append(ws); });
    $(other).each(function(i,ws) { $('#comments').append(ws); });
    $(useless).each(function(i,ws) { $('#comments').append(ws); });
  }
}

function fakemod(i,m) {
  if (i%m) return i%m;
  return m;
}


function ASC(s) {
	return s.charCodeAt(0);
}
function LET(s) {
	var n = ASC(s);
	if (n >= ASC("a") && n <= ASC("z")) return n - ASC("a") + 1;
	if (n >= ASC("A") && n <= ASC("Z")) return n - ASC("A") + 1;
	return 0;
}
function getField(V) {
  if (V.match(/-?[\d\.]+/)) return V;
  if (V.match(/\#/)) return currrow + 1;
  V = LET(V);
  if (V < 1 || V >= currtable.heads.length) return null;
  if (currtable.heads[V].match(/^=/))
  V = currtable.rows[currrow][V].calc.innerHTML;
  else
  V = currtable.rows[currrow][V].value;
  /* if (C == ":L")  V = String.fromCharCode(fakemod(parseInt(V),26)+64);
  if (C == ":l")  V = String.fromCharCode(fakemod(parseInt(V),26)+96);
  if (C == ":I")  { if (V.match(/[A-Z]/)) V = (V.charCodeAt(0)-65+1).toString(); else V=(V.charCodeAt(0)-97+1).toString();}
  if (C == ":b")  { V = parseInt(V,2).toString(); }
  if (C == ":B")  { V = parseInt(V.reverse(),2).toString(); } */
  return V;
}

function formulaElement(r,c,tinf) {
    tinf.rows[r][c].inp.hide();
    tinf.rows[r][c].calc.show();
}

var currtable;
var currrow;

function computeFormula(r,c,tinf) {
    normalElement(r,c,tinf);
    var formula = tinf.heads[c].substr(1);
    currtable = tinf;
    currrow = r;
    log("Trying the infix parser...");
    // okay, parse the formula.
    var V = infix_parse(formula);
    tinf.rows[r][c].calc.update(V);
    formulaElement(r,c,tinf);
}

function normalElement(r,c,tinf) {
    tinf.rows[r][c].calc.hide();
    tinf.rows[r][c].inp.show();
}

function init_table(table) {
  //TableKit.Sortable.init(table, {});
  //TableKit.Resizable.init(table, {});
}

function table_navigate(evt,i,j,len,id) {
  if ((evt.keyCode==13
    || evt.keyCode==40)
    && i < len-1) {
    $(id+'_'+(i+1)+'_'+j).focus();
  } else if (evt.keyCode == 38 && i > 0) {
    $(id+'_'+(i-1)+'_'+j).focus();
  }
}

function update_tables() {
 tables=$$('.pzt_table');
 tables.each(function(tid) { update_table(tid); });
}

function update_table(tid) {
  if ($(tid)) {
    var t=$(tid);
    tinf={}

    tinf.heads = t.select('th');
    tinf.heads.each(function(h,i) {
      if (!i) tinf.heads[i] = 0;
      else
      tinf.heads[i] = h.select('input')[0].value;
    });

    cells = t.select('td');
    tinf.rows=[];
    cells.each(function(cell,i) {
      var c=i%tinf.heads.length;
      var r=parseInt(i/tinf.heads.length);
      if (!tinf.rows[r]) tinf.rows[r] = [];
      tinf.rows[r][c] = { };
      if (!c) return;
      tinf.rows[r][c].value = cell.select('input')[0].value;
      tinf.rows[r][c].calc = cell.select('.calc')[0];
      tinf.rows[r][c].inp = cell.select('.inp')[0];
    });

    cells.each(function(cell,i) {
      var c=i%tinf.heads.length;
      var r=parseInt(i/tinf.heads.length);
      if (!c) return;
      if (tinf.heads[c].match(/^\=/)) {
         computeFormula(r,c,tinf);
      } else {
         normalElement(r,c,tinf);
      }
    });
  }
}

function update_table_cell(cid,txt,tid) {
	if (!$(cid)) return;
	$(cid).value = txt;
	update_table(tid);
}

// okay, this is an infix parser. Its goal is to be able to parse a message to do operations on columns.
// E.g., (C@(A+B):I+A[C]:I):L
// Just so we can continue to use shunting yard, we're going to do this:
// A[blah] => A$(blah), with $ as a high-precedence operator.
function infix_parse(s) {
	// evaluate a properly-formed expression in infix notation
	var output = [];
	var stack = [];
	// check for negatives first?
	var cn=true;
	var token;
	var precedence = { "$":4, ":":3, "@":2, "/":1, "*":1, "+":0, "-":0 };
	if (!s || !s.length) return 0;
	while (token=get_token(s,cn)) {
		s = token[1];
		if (token[2] == 1) {
			// first get the field value here.
			// now wait - if your last token was :, don't getField.
			if (stack[stack.length-1] == ":")
			output.push(token[0]);
			else
			output.push(getField(token[0])); cn = false;
		} else if (token[0] == '(') {
			stack.push(token[0]); cn = true;
		} else if (token[0] == ')') {
			cn = false;
			while (stack.length && stack[stack.length-1] != '(') {
				output.push(stack.pop());
			}
			if (!stack.length) return 0;
			stack.pop();
		} else {
			// you are an operator
			if (token[2] == 2) {
				log("Faking $ operator");
				output.push(getField(token[0]));
				token[0] = '$';
			}
			while (stack.length 
				&& stack[stack.length-1].match(/[\+\*\-\/\:\@\$]/)
				&& precedence[stack[stack.length-1]] >= precedence[token[0]]) {
				output.push(stack.pop());
			}
			stack.push(token[0]);
			cn = true;
		}
	}
	log("Stack is "+stack.join(","));
	log("Output is "+output.join(","));
	while (stack.length) {
		if (stack[stack.length-1] == '(') {
			return 0;
		}
		output.push(stack.pop());
	}

	log("Doing RPN");

	for (i=0;i<output.length;i++) {
		// push everything on the stack that isn't an operator
		if ((typeof output[i] == "string") && output[i].match(/[\+\*\-\/\:\@\$]/)) {
			log("Operator is "+output[i]);
			var x1 = stack.pop();
			var x2 = stack.pop();
			if (output[i] == '*') stack.push(asInt(x2)*asInt(x1));
			if (output[i] == '/') stack.push(asInt(x2)/asInt(x1));
			if (output[i] == '+') stack.push(asInt(x2)+asInt(x1));
			if (output[i] == '-') stack.push(asInt(x2)-asInt(x1));
			if (output[i] == ':') stack.push(cast(x2,x1));
			if (output[i] == '@') stack.push(rot(x2,x1));
			if (output[i] == '$') stack.push(ind(x2,x1));
			log("Pushed "+stack[stack.length-1]);
		} else {
			stack.push(output[i]);
		}
	}
	return stack[0];
}

function asInt(n) {
	// it is some kind of string.
	return parseFloat(n);
}

function cast(a,b) {
	if (b == "I") {
		return LET(a);
	}
	if (b == "B") return parseInt(a.reverse(),2);
	if (b == "b") return parseInt(a,2);
	if (b == "L") return String.fromCharCode(fakemod(parseInt(a),26)+64);
	if (b == "l") return String.fromCharCode(fakemod(parseInt(a),26)+96);
	if (b == "R") return a.reverse();
	return 0;
}

function rot(a,b) {
	var r = "";
	var i;
	for (i=0;i<a.length;i++) {
	 r += String.fromCharCode(fakemod(LET(a[i])-1 + parseInt(b),26)+65);
	}
	return r;
}

function ind(a,b) {
	log("Trying to index..."+a+" "+b);
	return a.replace(/[^A-Za-z]/g,'').substr(parseInt(b)-1,1);
}

function get_token(s,cn) {
	var i = 0;
	log("Parsing {"+s+"}");
	if (!s || !s.length) return null;
	if (!cn && s.match(/^[\+\*\/\(\-\)]/)) {
		return [s.slice(0,1),s.slice(1),0];
	}
	if (s.match(/^\-?[0-9]+\.?[0-9]*/)) {
		if (s.match(/^[\-]/)) i++;
		while (i < s.length && s[i].match(/[0-9\.]/)) i++;
		var token = s.slice(0,i);
		return [token, s.slice(i),1];
	}
	if (s.match(/^[A-Za-z\#]+([^A-Za-z\#\(\[]|$)/)) {
		while (i < s.length && !s[i].match(/[^A-Za-z\#\(]/)) i++;
		// it's just a string. return it.
		token = s.slice(0,i);
		return [token,s.slice(i),1];
	}
	if (s.match(/^[A-Za-z]+\(/)) {
		while (s[i] != '(') i++;
		// find the match
		var nest = 1;
		while (nest) {
			if (s[++i] == '(') nest ++;
			if (s[i] == ')') nest--;
		}
		token = s.slice(0,i+1);
		return [0,s.slice(i+1),1];
	}
	if (s.match(/^[A-Z]\[/)) {
		s = s.replaceAt(1,'(');
		var nest = 1;
		while (nest) {
			if (s[++i] == '[') nest ++;
			if (s[i] == ']') nest--;
		}
		s = s.replaceAt(i,')');
		token = s.slice(0,1);
		return [token,s.slice(1),2];
	}
	if (s.match(/^[\+\*\/\(\-\)\^\:\@]/)) {
		return [s.slice(0,1),s.slice(1),0];
	}
	log("Improper token "+s+"!");
	return null;
}


$(function() {
    $(".tablesorter").each(function() {
      console.log("Calling flexgrid on some table.");
      $(this).tablesorter();
    });
  });
