
<!-- TITLE/ -->

# Paged Plugin for [DocPad](http://docpad.org)

<!-- /TITLE -->


<!-- BADGES/ -->

[![Build Status](http://img.shields.io/travis-ci/docpad/docpad-plugin-paged.png?branch=master)](http://travis-ci.org/docpad/docpad-plugin-paged "Check this project's build status on TravisCI")
[![NPM version](https://badge.fury.io/js/docpad-plugin-paged.png)](https://npmjs.org/package/docpad-plugin-paged "View this project on NPM")
[![Gittip donate button](http://img.shields.io/gittip/bevry.png)](https://www.gittip.com/bevry/ "Donate weekly to this project using Gittip")
[![Flattr donate button](https://raw.github.com/balupton/flattr-buttons/master/badge-89x18.gif)](http://flattr.com/thing/344188/balupton-on-Flattr "Donate monthly to this project using Flattr")
[![PayPayl donate button](https://www.paypalobjects.com/en_AU/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QB8GQPZAH84N6 "Donate once-off to this project using Paypal")

<!-- /BADGES -->


This plugin provides [DocPad](https://docpad.org) with Paging. Documents can declare a number of pages that should be rendered for the document, or a collection over which the document should be rendered repeatedly.


## Install

```
docpad install paged
```


## Usage

### Explanation

The Paged plugin works by scanning the meta data of your document and looking for the `isPaged: true` meta data attribute.

- If you are wanting to page a listing of documents, then you would want to pass over the`pagedCollection: 'collectionName'` meta data attribute with the collection name being whatever collection you are listing.
- If you are wanting to split the current document into multiple pages, then you want to specify the `pageCount: 5` meta data attribute, where 5 is how many pages you want to have
- You can also specify the `pageSize: 5` meta data attribute (defaults to `1`) which indicates how many max items should be listed on an individual page

That being done, paged will scan your documents in the `renderBefore` action and clone your paged document for each page that will be needed. Setting the following attributes for each page document:

``` coffee
{
	count: 10       # total number of pages
	size: 5         # expected number of documents per page
	number: 0       # current page number
	startIdx: 0     # position of the first item in this page
	endIdx: 5       # position of the last item in this page
	pages: [50,1]   # document ids for each of the pages
}
```

You will interact with the paged plugin via the following template helpers that the paged plugin defines for you:

- `hasPrevPage(document ?= @getDocument())`
- `hasNextPage(document ?= @getDocument())`
- `getPrevPage(document ?= @getDocument())`
- `getNextPage(document ?= @getDocument())`
- `getPagedUrl(pageNumber ?= 0, document ?= @getDocument())`

It is important to note, that as the paged plugin clones the original document and injects the clones directly into the DocPad database, the extra pages (the clones) could appear in your content listings. To avoid this, be sure that your content listings filter out everything that has: `isPagedAuto: true`. For instance, a custom posts collection with the change applied would probably look like this:

``` coffee
module.exports =
	collections:
		posts: ->
			@getCollection('html').findAllLive(
				relativeOutDirPath: 'posts'
				isPagedAuto: $ne: true
			)
```


### Example: Paging a Collection Listing

Here is an example where we say create a `src/documents/posts.html.eco` file that pages out our `posts` custom collection.

It will create documents for each page for the `posts` collection in groups of 3. The first 3 documents in the collection will be rendered into a file called `posts.html` as normal, then the remaining documents from the collection will be rendered into subsequent files `posts.1.html`, `posts.2.html`, `posts.3.html` etc.

``` erb
---
title: 'Home'
layout: 'default'
isPaged: true
pagedCollection: 'posts'
pageSize: 3
---

<!-- Page Content -->
<% for document in @getCollection('posts').toJSON()[@document.page.startIdx...@document.page.endIdx]: %>
	<article id="post" class="post">
		<h1><a href='<%=document.url%>'><%= document.title %></a></h1>
		<div class="post-date"><%= document.date.toLocaleDateString() %></div>
		<div class="post-content">
			<%- document.contentRenderedWithoutLayouts %>
		</div>
	</article>
<% end %>

<!-- Page Listing -->
<div class="pagination">
	<ul>
		<!-- Previous Page Button -->
		<% unless @hasPrevPage(): %>
			<li class="disabled"><span>Prev</span></li>
		<% else: %>
			<li><a href="<%= @getPrevPage() %>">Prev</a></li>
		<% end %>

		<!-- Page Number Buttons -->
		<% for pageNumber in [0..@document.page.count-1]: %>
			<% if @document.page.number is pageNumber: %>
				<li class="active"><span><%= pageNumber + 1 %></span></li>
			<% else: %>
				<li><a href="<%= @getPageUrl(pageNumber) %>"><%= pageNumber + 1 %></a></li>
			<% end %>
		<% end %>

		<!-- Next Page Button -->
		<% unless @hasNextPage(): %>
			<li class="disabled"><span>Next</span></li>
		<% else: %>
			<li><a href="<%= @getNextPage() %>">Next</a></li>
		<% end %>
	</ul>
</div>
```


### Example: Splitting a Document into Multiple Pages

In this example we will split up a document say `src/documents/posts/awesome.html.eco` into 3 pages that have a max of 3 items per page.

``` erb
---
title: 'Awesome Pages Post'
layout: 'default'
isPaged: true
pageCount: 3
pageSize: 1
---

<!-- Page Content -->
<% if @document.page.number is 0: %>
	first awesome page
<% else if @document.page.number is 1: %>
	second awesome page
<% else if @document.page.number is 2: %>
	third awesome page
<% end %>

<!-- Page Listing -->
<div class="pagination">
	<ul>
		<!-- Previous Page Button -->
		<% unless @hasPrevPage(): %>
			<li class="disabled"><span>Prev</span></li>
		<% else: %>
			<li><a href="<%= @getPrevPage() %>">Prev</a></li>
		<% end %>
		
		<!-- Page Number Buttons -->
		<% for pageNumber in [0..@document.page.count-1]: %>
			<% if @document.page.number is pageNumber: %>
				<li class="active"><span><%= pageNumber + 1 %></span></li>
			<% else: %>
				<li><a href="<%= @getPageUrl(pageNumber) %>"><%= pageNumber + 1 %></a></li>
			<% end %>
		<% end %>
		
		<!-- Next Page Button -->
		<% unless @hasNextPage(): %>
			<li class="disabled"><span>Next</span></li>
		<% else: %>
			<li><a href="<%= @getNextPage() %>">Next</a></li>
		<% end %>
	</ul>
</div>
```


<!-- HISTORY/ -->

## History
[Discover the change history by heading on over to the `History.md` file.](https://github.com/docpad/docpad-plugin-paged/blob/master/History.md#files)

<!-- /HISTORY -->


<!-- CONTRIBUTE/ -->

## Contribute

[Discover how you can contribute by heading on over to the `Contributing.md` file.](https://github.com/docpad/docpad-plugin-paged/blob/master/Contributing.md#files)

<!-- /CONTRIBUTE -->


<!-- BACKERS/ -->

## Backers

### Maintainers

These amazing people are maintaining this project:

- Ben Delarre <ben@delarre.net> (https://github.com/benjamind)
- Benjamin Lupton <b@lupton.cc> (https://github.com/balupton)

### Sponsors

No sponsors yet! Will you be the first?

[![Gittip donate button](http://img.shields.io/gittip/bevry.png)](https://www.gittip.com/bevry/ "Donate weekly to this project using Gittip")
[![Flattr donate button](https://raw.github.com/balupton/flattr-buttons/master/badge-89x18.gif)](http://flattr.com/thing/344188/balupton-on-Flattr "Donate monthly to this project using Flattr")
[![PayPayl donate button](https://www.paypalobjects.com/en_AU/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QB8GQPZAH84N6 "Donate once-off to this project using Paypal")

### Contributors

These amazing people have contributed code to this project:

- Ben Delarre <ben@delarre.net> (https://github.com/benjamind) - [view contributions](https://github.com/docpad/docpad-plugin-paged/commits?author=benjamind)
- Benjamin Lupton <b@lupton.cc> (https://github.com/balupton) - [view contributions](https://github.com/docpad/docpad-plugin-paged/commits?author=balupton)

[Become a contributor!](https://github.com/docpad/docpad-plugin-paged/blob/master/Contributing.md#files)

<!-- /BACKERS -->


<!-- LICENSE/ -->

## License

Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT license](http://creativecommons.org/licenses/MIT/)

Copyright &copy; 2012+ Ben Delarre <ben@delarre.net> (http://www.delarre.net)

<!-- /LICENSE -->


