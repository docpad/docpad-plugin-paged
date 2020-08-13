'use strict'

# Test our plugin using DocPad's Testers
module.exports = require('docpad-plugintester')
	.test(
		# Test Configuration
		{
			testerName: 'paged without cleanurls'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				'cleanurls': false
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged without cleanurls with split disabled'
			autoExit: 'safe'
			outExpectedPath: __dirname+'/../test/out-expected-nosplit'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				'cleanurls': false
				paged:
					split: false
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged without cleanurls with index'
			outExpectedPath: __dirname+'/../test/out-expected-index'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				'cleanurls': false
				paged:
					index: 4
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged without cleanurls with prefix'
			outExpectedPath: __dirname+'/../test/out-expected-prefix'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				'cleanurls': false
				paged:
					prefix: 'page'
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls'
			outExpectedPath: __dirname+'/../test/out-expected-clean'
			autoExit: 'safe'
			removeWhitespace: true
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls with split disabled'
			outExpectedPath: __dirname+'/../test/out-expected-clean-nosplit'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				paged:
					split: false
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls with index'
			outExpectedPath: __dirname+'/../test/out-expected-clean-index'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				paged:
					index: 4
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls with prefix'
			outExpectedPath: __dirname+'/../test/out-expected-clean-prefix'
			autoExit: 'safe'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			plugins:
				paged:
					prefix: 'page'
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls on static'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
			plugins:
				paged:
					index: 0 # prevent compatibility check failing
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls on static with split disabled'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static-nosplit'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
			plugins:
				paged:
					split: false
					index: 0 # prevent compatibility check failing
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls on static with index'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static-index'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
			plugins:
				paged:
					index: 4
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls on static with prefix'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static-prefix'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
			plugins:
				paged:
					prefix: 'page'
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls on static with compatibility off'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static-nocompat'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
			plugins:
				paged:
					compatibility: false
		}
	)
	.test(
		# Test Configuration
		{
			testerName: 'paged with cleanurls on static with non-backwards compatible format'
			outExpectedPath: __dirname+'/../test/out-expected-clean-static-noback'
			removeWhitespace: true
		}

		# DocPad Configuration
		{
			env: 'static'
			plugins:
				paged:
					split: false
					index: 1
					prefix: ''
					compatibility: true
		}
	)
