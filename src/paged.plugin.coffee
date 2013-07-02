# Export Plugin
module.exports = (BasePlugin) ->
	# Define Plugin
	class PagedPlugin extends BasePlugin
		# Plugin Name
		name: 'paged'

		# Extend Collections
		# Define our paged collection that contains all of our paged documents
		extendCollections: (opts) ->
			# Prepare
			docpad = @docpad
			database = docpad.getDatabase()

			# Paged collection
			docpad.setCollections(
				paged: database.findAllLive(isPaged: true)
			)

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
					err =  "Could not find the page document #{pageId} which is page #{pageNumber} of #{@get('relativePath')}"
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

		# Render Before
		renderBeforePriority: 550  # run before clean urls
		renderBefore: (opts,next) ->
			# Prepare
			{TaskGroup} = require('taskgroup')
			docpad = @docpad
			{collection,templateData} = opts
			database = docpad.getDatabase()

			# Create a new collection to temporarily store our pages to render
			newPagesToRender = []

			# Completion callback
			tasks = new TaskGroup().setConfig(concurrency:0).once 'complete', (err) ->
				# Check
				return next(err)  if err

				# Add the pages to render to our render collection
				collection.add(newPagesToRender)
				database.add(newPagesToRender)

				# Complete
				return next()

			# Cycle through everything to render
			docpad.getCollection('paged').forEach (document) ->
				# Remove the previously generated pages
				if document.get('isPagedAuto')
					collection.remove(document)
					database.remove(document)
					return

				# Let the page meta specify count or use 1 by default
				numberOfPages = document.get('pageCount') or 1
				pageSize = document.get('pageSize') or 1
				lastDoc = pageSize * numberOfPages

				# if pagedCollection is specified then use that to determine number of pages
				if document.get('pagedCollection')
					pagedCollectionName = document.get('pagedCollection')
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
				document.setMeta(
					isPaged: true
					isPagedAuto: false
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
					[1...numberOfPages].forEach (pageNumber) ->
						# Create our new page
						pageDocument = document.clone()
						pageFilename = "#{basename}-#{pageNumber}.#{extension}"
						pageOutFilename = "#{outBasename}.#{pageNumber}.#{outExtension}"
						pageRelativePath = relativePath.replace(filename, pageFilename)

						# Apply the new properties
						pageDocument.attributes.urls = []
						pageDocument.setMeta(
							isPagedAuto: true
							page:  # as we do a shallow extend, make sure all page properties are defined
								count: numberOfPages
								size: pageSize
								number: pageNumber
								startIdx: pageNumber*pageSize
								endIdx: Math.min(pageNumber*pageSize + pageSize, lastDoc)
								pages: pages
							fullPath: null  # treat it as a virtual document
							relativePath: pageRelativePath
							filename: pageFilename
							outFilename: pageOutFilename
						)

						# Queue the normalization of the new document
						tasks.addTask (complete) ->
							pageDocument.normalize (err) ->
								# Check
								return complete(err)  if err

								# Add it to the list
								# Works as arrays are references
								pages.push(pageDocument.id)

								# Add it to the list that will be added to the database
								newPagesToRender.push(pageDocument)

								# Complete
								return complete()

			# Normalize the documents and finish up
			tasks.run()

			# Done
			true
