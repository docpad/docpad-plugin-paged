require('docpad').require('testers')
	.test({pluginPath: __dirname+'/..',pluginName:'paged',autoExit: 'safe'})
	.test({pluginPath: __dirname+'/..',pluginName:'paged',outExpectedPath: __dirname+'/out-expected-clean',autoExit:'safe'},{
		logLevel: 5,
		enabledPlugins: {
			'paged': true,
			'cleanurls': true,
			'eco': true
		}
	})
	.test({pluginPath: __dirname+'/..',pluginName:'paged',outExpectedPath: __dirname+'/out-expected-clean-static'},{
		logLevel: 5,
		enabledPlugins: {
			'paged': true,
			'cleanurls': true,
			'eco': true
		},
		env: 'static'
	});