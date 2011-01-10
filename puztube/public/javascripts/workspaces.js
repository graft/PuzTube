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