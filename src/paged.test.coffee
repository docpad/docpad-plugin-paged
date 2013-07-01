# Test our plugin using DocPad's Testers
require('docpad').require('testers')
	.test(
		# Test Configuration
		{
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			enabledPlugins:
				'cleanurls': false
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
	)