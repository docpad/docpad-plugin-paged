module.exports =
	collections:
		posts: ->
			@getCollection('html').findAllLive({
				relativeOutDirPath: 'posts'
				isPagedAuto: $ne: true
			}, [title:1])
