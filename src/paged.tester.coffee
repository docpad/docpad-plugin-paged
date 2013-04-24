# Export Plugin Tester
module.exports = (testers) ->
	# Define Plugin Tester
	class MyTester extends testers.RendererTester
		# Test Config
		config:
			removeWhitespace: true

		# DocPad Config
		docpadConfig:
			logLevel: 5
			enabledPlugins:
				'paged': true
				'eco': true