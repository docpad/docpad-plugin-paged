# Export Plugin
module.exports = (BasePlugin) ->
	# Requires
	{TaskGroup} = require('taskgroup')
	path = require('path')

	# Define Plugin
	class PagedPlugin extends BasePlugin
		# Plugin Name
		name: 'paged'

		# Default Configuration
		config:
			split: true
			index: 1
			prefix: ''
			compatibility: true

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

			# Get a collection of the models on the current page
			templateData.getPageCollection = (collectionName, start, finish) ->
				collectionName ?= 'html'
				collection = @getCollection(collectionName)
				start ?= @document.page?.startIdx or 0
				finish ?= @document.page?.endIdx or collection.models.length
				subCollection = new docpad.FilesCollection(collection.models[start...finish])
				return subCollection

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

			# Extract
			filePath = document.getFilePath()
			pages = (document.get('page')?.pages or [])

			# Check
			if pages.length is 0
				next?()
				return @

			# Log
			docpad.log('debug', "Remove pages for:", filePath)

			# Completion callback
			tasks = new TaskGroup().once 'completed', (err) ->
				# Check
				return next?(err)  if err

				# Log
				docpad.log('debug', "Removed pages for:", filePath)

				# Forward
				return next?()

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
			config = @config

			# Create a new collection to temporarily store our pages to render
			newPagesToRender = []

			# Fetch the source pages
			sourcePageDocuments = collection.findAll(
				isPaged: true
				isPagedAuto: $ne: true
			)

			# Check
			if sourcePageDocuments.length is 0
				next()
				return @

			# Log
			docpad.log('info', "Adding pages for #{sourcePageDocuments.length} documents...")

			# Completion callback
			tasks = new TaskGroup().once 'completed', (err) ->
				# Check
				return next(err)  if err

				# Log
				docpad.log('info', "Added pages")

				# Forward
				return next()

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
				filePath = document.getFilePath()
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
						# Prepare our new page
						newPageNumber = pageNumber + config.index
						if config.split
							pageFilename = "index.#{extension}"
							pageOutFilename = "index.#{outExtension}"
							pagePathBasename = if basename is 'index' then '' else basename
							pageRelativePath = path.join path.dirname(relativePath), pagePathBasename, config.prefix, newPageNumber.toString(), pageFilename
						else
							pageFilename = "#{basename}-#{config.prefix}#{newPageNumber}.#{extension}"
							pageOutFilename = "#{outBasename}.#{config.prefix}#{newPageNumber}.#{outExtension}"
							pageRelativePath = relativePath.replace(filename, pageFilename)

						# Log
						docpad.log('info', "Creating page #{pageNumber} for #{filePath} at #{pageRelativePath}")

						# Create our new page
						pageDocument = docpad.cloneModel?(document) ? document.clone()

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

						# Maintain compatibility with old url format e.g. index.1.html
						secondaryOutFilename = "#{basename}.#{pageNumber}.#{outExtension}"
						secondaryUrl = relativePath.replace(filename, secondaryOutFilename).replace("\\","/")
						validForRedirect = not config.split and config.index isnt 0 and config.prefix is ""
						if config.compatibility and
						not validForRedirect and
						secondaryOutFilename isnt pageOutFilename
							pageDocument.addUrl("/#{secondaryUrl}")
							docpad.log('info', "Created secondary url structure for #{pageOutFilename} at /#{secondaryUrl}")
						else
							docpad.log('warning', "Unable to create secondary url structure for #{pageOutFilename} at /#{secondaryUrl}")

						# Normalize our properties of the new document
						pageDocument.normalize (err) ->
							# Check
							return complete(err)  if err

							# Extract
							pageFilePath = pageDocument.getFilePath()

							# Log
							# console.log 'ADD', pageDocument.id, pageDocument.get('outPath')
							# console.log 'FOR', document.id, document.get('outPath')
							# console.log '=> ', database.pluck('id').sort().join(',')

							# Log
							docpad.log('debug', "Adding page #{pageNumber} for #{filePath} at #{pageFilePath}")

							# Add it to the list
							pages.push(pageDocument.id)

							# Add it to the database
							collection.add(pageDocument)
							database.add(pageDocument)

							# Log
							docpad.log('debug', "Created and added page #{pageNumber} for #{filePath} at #{pageFilePath}")

							# Log
							# console.log '=> ', database.pluck('id').sort().join(',')

							# Complete
							return complete()

			# Normalize the documents and finish up
			tasks.run()

			# Done
			true
