$(function() {
	$('body').on('click','[data-puzzle-tid]',function() {
		var pzr = $(this).data('puzzle-tid');
		var rid = 'r'+$(this).data('round-id');
		var fields = $.map( $('#'+rid+'_form input[id^='+rid+']'), function(e,i) {
			return $(e).attr('id').replace(rid+'_','')
		});
		console.log("Processing update from "+pzr+" "+rid+" "+fields);
		$(fields).each(function(i,f){
			if (f == "meta")
				$('#'+rid+"_"+f).val( $('#'+pzr+'_'+f).is(':checked') ? 1 : 0 );
			else
        			$('#'+rid+"_"+f).val( $('#'+pzr+"_"+f).val() );
				console.log('Setting '+rid+'_'+f);
			});
		$('#' + rid + "_form").submit();
		return false;
	});
});
