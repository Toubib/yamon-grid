# yamon-grid config file
#

CONFIG={
	'site_1' => { #website name
		'href' => 'https://url1', #website link
		'astr_url' => 'https://url1/nagios/astreinte.php', #alert list in json format, business critical only
		'full_url' => 'https://url1/nagios/astreinte.php?all=1', #alert list in json format, full
		'use_cert' => false, # use ssl client certificate ?
		'yamon' => false #is this website a yamon app ?
	},
	'site_2' => { #website name
		'href' => 'https://yamon.url2/current_alerts', #website link
		'astr_url' => 'https://yamon.url2/current_alerts_astreinte.json', #alert list in json format, business critical only
		'full_url' => 'https://yamon.url2/current_alerts.json', #alert list in json format, full
		'use_cert' => true, # use ssl client certificate ?
		'yamon' => true #is this website a yamon app ?
	}
}
