/*
	Supporting functions for gamegap phonegap plugin
 
 */


function getPhoneGapURL()
{
	var args = arguments;
	var uri = [];
	var dict = null;
	for (var i = 1; i < args.length; i++) {
		var arg = args[i];
		if (arg == undefined || arg == null)
			arg = '';
		if (typeof(arg) == 'object')
			dict = arg;
		else
			uri.push(encodeURIComponent(arg));
	}
	var url = "gap://" + args[0] + "/" + uri.join("/");
	if (dict != null) {
		var query_args = [];
		for (var name in dict) {
			if (typeof(name) != 'string')
				continue;
			query_args.push(encodeURIComponent(name) + "=" + encodeURIComponent(dict[name]));
		}
		if (query_args.length > 0)
			url += "?" + query_args.join("&");
	}
	return url;
}

function GameGap_NextFrame(timeDiff) {
	// default impl - must override.
}