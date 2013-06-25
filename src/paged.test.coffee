# Test our plugin using DocPad's Testers
require('docpad').require('testers')
	.test(
		# Test Configuration
		{
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			autoExit: 'safe'
		}

		# DocPad Configuration
		{
			logLevel: 5
			enabledPlugins:
				'paged': true
				'cleanurls': false
				'eco': true
		}
	)
	.test(
		# Test Configuration
		{
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			logLevel: 5
			enabledPlugins:
				'paged': true
				'cleanurls': true
				'eco': true
		}
	)
	.test(
		# Test Configuration
		{
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			logLevel: 5
			enabledPlugins:
				'paged': true
				'cleanurls': true
				'eco': true
			env: 'static'
		}
	)