# Test our plugin using DocPad's Testers
require('docpad').require('testers')
	.test(
		# Test Configuration
		{
			testerName: 'paged without cleanurls'
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
			testerName: 'paged with cleanurls'
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
			testerName: 'paged with cleanurls on static'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls with cleanurl'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-cleanurl'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				paged:
					cleanurl: true
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls with cleanurl and prefix'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-cleanurl-prefix'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				paged:
					cleanurl: true
					pagePrefix: 'page'
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls with cleanurl and different starting number'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-cleanurl-startnum'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				paged:
					cleanurl: true
					startNum: 2
		}
	)
