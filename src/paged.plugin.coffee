# Export Plugin
module.exports = (BasePlugin) ->
	# Requires
	{TaskGroup} = require('taskgroup')

	# Define Plugin
	class PagedPlugin extends BasePlugin
		# Plugin Name
		name: 'paged'

		# Extend Collections
		# Remove our auto pages as our source pages are removed
		extendCollections: (opts) ->
			# Prepare
			me = @
			docpad = @docpad

			# Remove a paged collection
			docpad.getFiles(
				isPaged: true
				isPagedAuto: $ne: true
			).on 'remove', (model) ->
				me.removePagesFor(model)

			# Chain
			@

		# Extend Template Data
		# Add our tempate helpers
		extendTemplateData: (opts) ->
			# Prepare
			docpad = @docpad
			{templateData} = opts

			# Get the url of the desired page
			templateData.getPageUrl = (pageNumber, document) ->
				# Prepare
				document ?= @getDocument()
				page = document.get('page')
				pageNumber ?= page?.number ? 0

				# Fetch
				pageId = page.pages[pageNumber]
				pageDocument = docpad.getFileById(pageId)

				# Check
				unless pageDocument?
					relativePath = document.get('relativePath')
					err =  "Could not find document with id #{pageId} that is page #{pageNumber} of #{relativePath}"
					docpad.error(err)
					pageUrl = err
				else
					pageUrl = pageDocument.get('url')

				# Return
				return pageUrl

			# Do we have another page left?
			templateData.hasNextPage = (document) ->
				# Prepare
				document ?= @getDocument()
				page = document.get('page')

				# Check
				has = page.number < page.count-1

				# Return
				return has

			# Return the URL of the next page
			templateData.getNextPage = (document) ->
				# Prepare
				document ?= @getDocument()
				page = document.get('page')
				result = '#'

				# Check
				if page.number < page.count-1
					result = @getPageUrl(page.number+1, document)

				# Default
				return result

			# Do we have a previous page?
			templateData.hasPrevPage = (document) ->
				# Prepare
				document ?= @getDocument()
				page = document.get('page')

				# Check
				has = page.number > 0

				# Return
				return has

			# Get the URL of the previous page
			templateData.getPrevPage = (document) ->
				# Prepare
				document ?= @getDocument()
				page = document.get('page')
				result = '#'

				# Check
				if page.number > 0
					result = @getPageUrl(page.number-1, document)

				# Return
				return result

			# Done
			true

		# Remove Pages For
		removePagesFor: (document, collection, next) ->
			# Prepare
			docpad = @docpad
			database = docpad.getDatabase()

			# Completion callback
			tasks = new TaskGroup()
			tasks.once('complete', next)  if next

			# Extract
			pages = (document.get('page')?.pages or [])

			# Log
			# console.log 'START REMOVE FOR', document.id, document.get('outPath'), pages

			# Queue deletions
			pages.forEach (pageId) ->
				# Ignore if we are ourself
				return  if pageId is document.id

				# Fetch the page from the database
				pageDocument = database.get(pageId)

				# Ignore if we already don't exist
				return  unless pageDocument

				# Log
				# console.log 'REMOVE', pageDocument.id, pageDocument.get('outPath')
				# console.log 'FOR', document.id, document.get('outPath')
				# console.log '=> ', database.pluck('id').sort().join(',')

				# Remove from database
				collection?.remove(pageDocument)
				database.remove(pageDocument)

				# Log
				# console.log '=> ', database.pluck('id').sort().join(',')

				# Delete the out file
				tasks.addTask (complete) ->
					pageDocument.delete(complete)

			# Run tasks
			tasks.run()

			# Chain
			@

		# Render Before
		renderBeforePriority: 550  # run before clean urls
		renderBefore: (opts,next) ->
			# Prepare
			me = @
			docpad = @docpad
			{collection,templateData} = opts
			database = docpad.getDatabase()

			# Create a new collection to temporarily store our pages to render
			newPagesToRender = []

			# Completion callback
			tasks = new TaskGroup().once('complete', next)

			# Fetch the source pages
			sourcePageDocuments = collection.findAll(
				isPaged: true
				isPagedAuto: $ne: true
			)

			# Remove their existing associated auto pages first
			sourcePageDocuments.forEach (document) ->
				tasks.addTask (complete) ->
					return me.removePagesFor(document, collection, complete)

			# Add the new auto pages once all the auto pages have been removed
			sourcePageDocuments.forEach (document) ->  tasks.addGroup (addGroup, addTask) ->
				# Let the page meta specify count or use 1 by default
				meta = document.getMeta()
				numberOfPages = meta.get('pageCount') or 1
				pageSize = meta.get('pageSize') or 1
				lastDoc = pageSize * numberOfPages

				# if pagedCollection is specified then use that to determine number of pages
				if meta.get('pagedCollection')
					pagedCollectionName = meta.get('pagedCollection')
					pagedCollection = docpad.getCollection(pagedCollectionName)
					numberOfPages = Math.ceil(pagedCollection.length / pageSize)
					lastDoc = pagedCollection.length

				# Prepare
				relativePath = document.get('relativePath')
				filename = document.get('filename')
				basename = document.get('basename')
				extension = document.get('extensions').join('.')
				outFilename = document.get('outFilename')
				outBasename = document.get('outBasename')
				outExtension = document.get('outExtension')
				url = document.get('url')
				pages = [document.id]

				# Log
				# docpad.log('debug', "Document #{relativePath} has #{numberOfPages} pages")

				# Create a page object for this page
				document.set(
					isPaged: true
					isPagedAuto: false
					isPagedFor: false
					page:
						count: numberOfPages
						size: pageSize
						number: 0
						startIdx: 0
						endIdx: Math.min(pageSize, lastDoc)
						pages: pages
				)

				# Loop over the number of pages we have and generate a clone of this document for each
				if numberOfPages > 1
					[1...numberOfPages].forEach (pageNumber) ->  addTask (complete) ->
						# Create our new page
						pageDocument = document.clone()
						pageFilename = "#{basename}-#{pageNumber}.#{extension}"
						pageOutFilename = "#{outBasename}.#{pageNumber}.#{outExtension}"
						pageRelativePath = relativePath.replace(filename, pageFilename)

						# Apply the new properties
						pageDocument.attributes.urls = []
						pageDocument.set(
							isPagedAuto: true
							isPagedFor: document.id
							page:  # as we do a shallow extend, make sure all page properties are defined
								count: numberOfPages
								size: pageSize
								number: pageNumber
								startIdx: pageNumber*pageSize
								endIdx: Math.min(pageNumber*pageSize + pageSize, lastDoc)
								pages: pages
						)
						pageDocument.setMeta(
							fullPath: null  # treat it as a virtual document
							relativePath: pageRelativePath
							filename: pageFilename
							outFilename: pageOutFilename
						)

						# Normalize our properties of the new document
						pageDocument.normalize (err) ->
							# Check
							return complete(err)  if err

							# Log
							# console.log 'ADD', pageDocument.id, pageDocument.get('outPath')
							# console.log 'FOR', document.id, document.get('outPath')
							# console.log '=> ', database.pluck('id').sort().join(',')

							# Add it to the list
							pages.push(pageDocument.id)

							# Add it to the database
							collection.add(pageDocument)
							database.add(pageDocument)

							# Log
							# console.log '=> ', database.pluck('id').sort().join(',')

							# Complete
							return complete()

			# Normalize the documents and finish up
			tasks.run()

			# Done
			true
