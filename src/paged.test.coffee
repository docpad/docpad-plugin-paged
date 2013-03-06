# Test our plugin using DocPad's Testers
require('docpad').require('testers')
	.test({
		pluginPath: __dirname+'/..'
		pluginName: 'paged'
		autoExit: 'safe'
	})
	.test({
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean'
			autoExit:'safe'
		},{
			logLevel: 5
			enabledPlugins: {
				'paged': true
				'cleanurls': true
				'eco': true
			}
	})
	.test({
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static'
		},{
			logLevel: 5
			enabledPlugins: {
				'paged': true
				'cleanurls': true
				'eco': true
			}
			env: 'static'
	})