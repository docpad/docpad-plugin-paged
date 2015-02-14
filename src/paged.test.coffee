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
			testerName: 'paged without cleanurls with split enabled'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-split'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			enabledPlugins:
				'cleanurls': false
			plugins:
				paged:
					split: true
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged without cleanurls and prefix'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-prefix'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			enabledPlugins:
				'cleanurls': false
			plugins:
				paged:
					prefix: 'page'
		}
	).test(
		# Test Configuration
		{
			testerName: 'paged without cleanurls and different index'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-index'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			enabledPlugins:
				'cleanurls': false
			plugins:
				paged:
					index: 1
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
			testerName: 'paged with cleanurls with split enabled'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-split'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				paged:
					split: true
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls with split enabled and prefix'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-split-prefix'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				paged:
					split: true
					prefix: 'page'
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls with split enabled and different index'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-split-index'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				paged:
					split: true
					index: 1
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
			testerName: 'paged with cleanurls on static with split enabled'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static-split'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
			plugins:
				paged:
					split: true
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls on static with split enabled and prefix'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static-split-prefix'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
			plugins:
				paged:
					split: true
					prefix: 'page'
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls on static with split enabled and different index'
			testerClass: 'RendererTester'
			pluginPath: __dirname+'/..'
			pluginName: 'paged'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static-split-index'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
			plugins:
				paged:
					split: true
					index: 1
		}
	)
