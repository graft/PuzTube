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
    useless.each(function(ws) { $('comments').insert({top:ws}); });
    other.each(function(ws) { $('comments').insert({top:ws}); });
    normal.each(function(ws) { $('comments').insert({top:ws}); });
    high.each(function(ws) { $('comments').insert({top:ws}); });
  }
}
