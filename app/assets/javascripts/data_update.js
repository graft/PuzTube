$(function() {

	/* Convenience for forms or links that return HTML from a remote ajax call.
	 *
	 * The returned markup will be inserted into the element id specified.
	 *
	 * */

	$('body').on('ajax:success','a[data-update-target], form[data-update-target]', function(evt, data) {
		var target = $(this).data('update-target');
		$('#' + target).html(data);
    if (Grid) Grid.prepare($('#' + target));
	});
	$('body').on('click','[data-click-submit]',function() {
		var target = $(this).data('click-submit');
		$('#' + target).submit();
		return false;
	});
	$('body').on('change','[data-change-submit]',function() {
		var target = $(this).data('change-submit');
		console.log("Submitting "+target);
		$('#' + target).submit();
	});
});
