# Export Plugin
module.exports = (BasePlugin) ->
	{TaskGroup} = require('taskgroup')

	# Define Plugin
	class PagedPlugin extends BasePlugin
		# Plugin Name
		name: 'paged'

		# Extend Collections
		# Extend our Prototypes with the Paged Helpers
		extendCollections: (opts) ->
			# Prepare
			docpad = @docpad
			database = docpad.getDatabase()
			{DocumentModel} = docpad

			# Paged collection
			docpad.setCollections(
				paged: database.findAllLive(isPaged: true)
			)

			# Get the url of the desired page
			DocumentModel::getPagedUrl ?= (pageNumber) ->
				# Prepare
				page = @get('page')
				pageNumber ?= page?.number ? 0

				# Fetch
				pageId = page.pages[pageNumber]
				pageDocument = docpad.getFileById(pageId)
				unless pageDocument?
					docpad.log('warn', "Could not find the page document #{pageId} which is page #{pageNumber} of #{@get('relativePath')}")
					pageUrl = '404'
				else
					pageUrl = pageDocument.get('url')

				# Return
				return pageUrl

			# Do we have another page left?
			DocumentModel::hasNextPage ?= ->
				# Prepare
				page = @get('page')

				# Check
				has = page.number < page.count-1

				# Return
				return has

			# Return the URL of the next page
			DocumentModel::getNextPage ?= ->
				# Prepare
				page = @get('page')
				result = '#'

				# Check
				if page.number < page.count-1
					result = @getPagedUrl(page.number+1)

				# Default
				return result

			# Do we have a previous page?
			DocumentModel::hasPrevPage ?= ->
				# Prepare
				page = @get('page')

				# Check
				has = page.number > 0

				# Return
				return has

			# Get the URL of the previous page
			DocumentModel::getPrevPage ?= ->
				# Prepare
				page = @get('page')
				result = '#'

				# Check
				if page.number > 0
					result = @getPagedUrl(page.number-1)

				# Return
				return result

		# Render Before
		renderBefore: (opts,next) ->
			# Prepare
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
				pageSize = document.get('pageSize') or 5
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
				pages = [document.cid]

				# Log
				docpad.log('debug', "Document #{relativePath} has #{numberOfPages} pages")

				# Create a page object for this page
				document.set(
					isPaged: true
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
						pageOutFilename = "#{outBasename}-#{pageNumber}.#{outExtension}"

						# Apply the new properties
						pageDocument.set(
							isPagedAuto: document.cid
							page:  # as we do a shallow extend, make sure all page properties are defined
								count: numberOfPages
								size: pageSize
								number: pageNumber
								startIdx: pageNumber*pageSize
								endIdx: Math.min(pageNumber*pageSize + pageSize, lastDoc)
								pages: pages
							fullPath: null  # treat it as a virtual document
							relativePath: relativePath.replace(filename, pageFilename)
							filename: pageFilename
							outFilename: pageOutFilename
							url: url.replace(outFilename, pageOutFilename)
						)

						# Queue the normalization of the new document
						tasks.addTask (complete) ->
							pageDocument.normalize (err) ->
								# Check
								return complete(err)  if err

								# Add it to the list
								# Works as arrays are references
								pages.push(pageDocument.cid)

								# Add it to the list that will be added to the database
								newPagesToRender.push(pageDocument)

								# Complete
								return complete()

			# Normalize the documents and finish up
			tasks.run()

			# Done
			true
