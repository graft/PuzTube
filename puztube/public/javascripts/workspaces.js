String.prototype.reverse = function() {
    var s = "";
    var i = this.length;
    while (i>0) {
        s += this.substring(i-1,i);
        i--;
    }
    return s;
}

Element.addMethods({
    show : function(element) {
        element = $(element);
        element.removeClassName('hidden') //should be enough to show Element, but 
               .setStyle({display: ''}); //in case the element was hidden with inline script
    },
    hide : function(element) {
        element = $(element);
        element.addClassName('hidden'); //hide element with css                
    }
});

function showUpload(id) {
  Element.show(id+'.upload');
  Element.show(id+'.cancelbutton');
  Element.hide(id+'.addbutton');
}

function hideUpload(id) {
  Element.hide(id+'.upload');
  Element.hide(id+'.cancelbutton');
  Element.show(id+'.addbutton');
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

  function create_workspace(txt) {
    if ($('comments')) $('comments').insert({ top: txt });
    sortWorkspaces();
  }

function jug_table_update(dv,txt,tid) {
  jug_ws_update(dv,txt);
  init_table(tid);
}

  function jug_ws_update(dv,txt) {
    if ($(dv)) {
      if ($(dv+'.editing')) {
        if ($(dv+'.conflict')) $(dv+'.conflict').update('<font style="color:red;font-weight:bold;">Edit Conflict!</font>');
      } else
        $(dv).update(txt);
      sortWorkspaces();
    }
  }
  
function sortWorkspaces() {
  workspaces = $$('div.workspace');
  high = []
  normal = []
  useless = []
  other = []
  workspaces.each(function(ws) {
    fd = ws.firstDescendant();
    if (fd) {
      if (fd.hasClassName('prioHigh_title')) high.push(ws);
      else if (fd.hasClassName('prioNormal_title')) normal.push(ws);
      else if (fd.hasClassName('prioUseless_title')) useless.push(ws);
      else other.push(ws);
    }
  });
  if ($('comments')) {
    $('comments').update();
    high.each(function(ws) { $('comments').insert({bottom:ws}); });
    normal.each(function(ws) { $('comments').insert({bottom:ws}); });
    other.each(function(ws) { $('comments').insert({bottom:ws}); });
    useless.each(function(ws) { $('comments').insert({bottom:ws}); });
  }
}

function fakemod(i,m) {
  if (i%m) return i%m;
  return m;
}
function getField(r,c,tinf,V,C) {
  if (V.match(/\d+/)) return V;
  V = V.charCodeAt(0) - 65+1;
  if (V < 1 || V >= tinf.heads.length) return null;
  if (tinf.heads[V].match(/^=/))
  V = tinf.rows[r][V].calc.innerHTML;
  else
  V = tinf.rows[r][V].value;
  if (C == ":L")  V = String.fromCharCode(fakemod(parseInt(V),26)+64);
  if (C == ":l")  V = String.fromCharCode(fakemod(parseInt(V),26)+96);
  if (C == ":I")  { if (V.match(/[A-Z]/)) V = (V.charCodeAt(0)-65+1).toString(); else V=(V.charCodeAt(0)-97+1).toString();}
  if (C == ":b")  { V = parseInt(V,2).toString(); }
  if (C == ":B")  { V = parseInt(V.reverse(),2).toString(); }
  return V;
}

function formulaElement(r,c,tinf) {
    tinf.rows[r][c].inp.hide();
    tinf.rows[r][c].calc.show();
    var formula = tinf.heads[c].substr(1);
    if (formula.match(/([A-Z]|\d+)(:[LbBIl])?([\+\-\*\/\%\@\[])([A-Z]|\d+)(:[LbBIl])?(\])?/)) {
       var LV=RegExp.$1;
       var LC=RegExp.$2;
       var OP=RegExp.$3;
       var RV=RegExp.$4;
       var RC=RegExp.$5;
       LV = getField(r,c,tinf,LV,LC);
       RV = getField(r,c,tinf,RV,RC);
       if (LV == null || RV == null) { tinf.rows[r][c].calc.update(); return; }
       switch(OP) {
         case "+": LV = parseInt(LV)+parseInt(RV); break;
         case "-": LV = parseInt(LV)-parseInt(RV); break;
         case "*": LV = parseInt(LV)*parseInt(RV); break;
         case "/": LV = parseInt(LV)/parseInt(RV); break;
         case "%": LV = parseInt(LV)%parseInt(RV); break;
         case "@":
		if (LV.match(/[A-Z]/))
			 LV = String.fromCharCode(fakemod(LV.charCodeAt(0)-65+1+parseInt(RV),26)+65);
		else 
			LV = String.fromCharCode(fakemod(LV.charCodeAt(0)-97+1+parseInt(RV),26)+97);
		break;
         case "[":
		LV = LV.replace(/[^A-Za-z]/g,'').substr(parseInt(RV)-1,1);
                break;
       }
       tinf.rows[r][c].calc.update(LV);
       return;
    }
    if (formula.match(/([A-Z]|\d+)(:[LbBIl])/)) {
       tinf.rows[r][c].calc.update(getField(r,c,tinf,RegExp.$1,RegExp.$2));
    }
}

function normalElement(r,c,tinf) {
    tinf.rows[r][c].calc.hide();
    tinf.rows[r][c].inp.show();
}

function init_table(table) {
  TableKit.Sortable.init(table, {});
  TableKit.Resizable.init(table, {});
}

function update_tables() {
 tables=$$('.pzt_table');
 tables.each(function(tid) { update_table(tid); });
}

function update_table(tid) {
  if ($(tid)) {
    var t=$(tid);
    var tinf={}
    tinf.heads = t.select('th');
    tinf.cols=[];
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
         formulaElement(r,c,tinf);
      } else {
         normalElement(r,c,tinf);
      }
    });
  }
}
