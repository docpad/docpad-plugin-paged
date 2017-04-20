<!-- TITLE/ -->

<h1>Paged Plugin for [DocPad](http://docpad.org)</h1>

<!-- /TITLE -->


<!-- BADGES/ -->

<span class="badge-travisci"><a href="http://travis-ci.org/docpad/docpad-plugin-paged" title="Check this project's build status on TravisCI"><img src="https://img.shields.io/travis/docpad/docpad-plugin-paged/master.svg" alt="Travis CI Build Status" /></a></span>
<span class="badge-npmversion"><a href="https://npmjs.org/package/docpad-plugin-paged" title="View this project on NPM"><img src="https://img.shields.io/npm/v/docpad-plugin-paged.svg" alt="NPM version" /></a></span>
<span class="badge-npmdownloads"><a href="https://npmjs.org/package/docpad-plugin-paged" title="View this project on NPM"><img src="https://img.shields.io/npm/dm/docpad-plugin-paged.svg" alt="NPM downloads" /></a></span>
<span class="badge-daviddm"><a href="https://david-dm.org/docpad/docpad-plugin-paged" title="View the status of this project's dependencies on DavidDM"><img src="https://img.shields.io/david/docpad/docpad-plugin-paged.svg" alt="Dependency Status" /></a></span>
<span class="badge-daviddmdev"><a href="https://david-dm.org/docpad/docpad-plugin-paged#info=devDependencies" title="View the status of this project's development dependencies on DavidDM"><img src="https://img.shields.io/david/dev/docpad/docpad-plugin-paged.svg" alt="Dev Dependency Status" /></a></span>
<br class="badge-separator" />
<span class="badge-patreon"><a href="https://patreon.com/bevry" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-gratipay"><a href="https://www.gratipay.com/bevry" title="Donate weekly to this project using Gratipay"><img src="https://img.shields.io/badge/gratipay-donate-yellow.svg" alt="Gratipay donate button" /></a></span>
<span class="badge-flattr"><a href="https://flattr.com/profile/balupton" title="Donate to this project using Flattr"><img src="https://img.shields.io/badge/flattr-donate-yellow.svg" alt="Flattr donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
<span class="badge-bitcoin"><a href="https://bevry.me/bitcoin" title="Donate once-off to this project using Bitcoin"><img src="https://img.shields.io/badge/bitcoin-donate-yellow.svg" alt="Bitcoin donate button" /></a></span>
<span class="badge-wishlist"><a href="https://bevry.me/wishlist" title="Buy an item on our wishlist for us"><img src="https://img.shields.io/badge/wishlist-donate-yellow.svg" alt="Wishlist browse button" /></a></span>
<br class="badge-separator" />
<span class="badge-slackin"><a href="https://slack.bevry.me" title="Join this project's slack community"><img src="https://slack.bevry.me/badge.svg" alt="Slack community badge" /></a></span>

<!-- /BADGES -->


This plugin provides [DocPad](https://docpad.org) with Paging. Documents can declare a number of pages that should be rendered for the document, or a collection over which the document should be rendered repeatedly.


<!-- INSTALL/ -->

<h2>Install</h2>

Install this DocPad plugin by entering <code>docpad install paged</code> into your terminal.

<!-- /INSTALL -->


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
<% for document in @getPageCollection('posts').toJSON(): %>
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
				<li><a href="<%= @getPagedUrl(pageNumber) %>"><%= pageNumber + 1 %></a></li>
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
				<li><a href="<%= @getPagedUrl(pageNumber) %>"><%= pageNumber + 1 %></a></li>
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

<!-- CONFIGURE/ -->

## Configure
For information on customising your plugin configuration you can refer to the [DocPad FAQ](https://github.com/bevry/docpad/wiki/FAQ)

You can customise the URL format by setting custom preferences. The default configuration is:

	split: true
	prefix: ''
	index: 1
	compatibility: true

The examples below are with the [Clean URLs Plugin](https://github.com/docpad/docpad-plugin-cleanurls) installed to remove the file extensions, but each option also works without it. Each option is also compatible with CLean URLs Plugin's static redirection generation.

### split

`split: true`: The url will be split into multiple parts

For normal documents (e.g. archives.html), the generated url pattern will be:

* /archives/
* /archives/2/
* /archives/3/
* /archives/4/
* etc...

For a document named index.html, the generated url pattern will be:

* /
* /2/
* /3/
* /4/
* etc...

`split: false`: The url will be one single part

For normal documents (e.g. archives.html), the generated url pattern will be:

* /archives
* /archives.2/
* /archives.3/
* /archives.4/
* etc...

For a document named index.html, the generated url pattern will be:

* /
* index.2/
* index.3/
* index.4/
* etc...

### index

Set `index` to set the page number for the index page.

For example, after setting `index: 1`, the generated url pattern will be:

* /archives/
* /archives/2/
* /archives/3/
* /archives/4/
* etc...

After setting `index: 0`, the generated url pattern will be:

* /archives/
* /archives/1/
* /archives/2/
* /archives/3/
* etc...

### prefix

Set `prefix` to add a prefix path to the page numbers.

For example, after setting `prefix: 'page'`, the generated url pattern will be:

* /archives/
* /archives/page/2/
* /archives/page/3/
* /archives/page/4/
* etc...

### compatibility

Set `compatibility: true` to maintain backwards compatibility with the older URL structure.

For example, when combined with `prefix: 'page'` and `index: 1`, the generated url will be:

* /archives/
* /archives/page/2/ (also available at /archives.1/)
* /archives/page/3/ (also available at /archives.2/)
* /archives/page/4/ (also available at /archives.3/)

**NOTE**: There is one configuration combination in which backwards-compatibility will not be enabled:

    split: false
    index: [anything other than 0]
    prefix: ''
    compatibility: true

Setting your configuration to the above will not create the secondary url for each page, to prevent it clashing with the primary url.

Set `compatibility: false` to prevent the additional urls being generated.

### Combining settings

The settings can be combined to create alternative URL structure. For example, if we configure the plugin with the following options:

```
split: false
prefix: 'page.'
index: 0
```

The generated url pattern will be:

* /archives
* /archives.page.1/
* /archives.page.2/
* /archives.page.3/
* etc...

<!-- /CONFIGURE -->

<!-- HISTORY/ -->

<h2>History</h2>

<a href="https://github.com/docpad/docpad-plugin-paged/blob/master/HISTORY.md#files">Discover the release history by heading on over to the <code>HISTORY.md</code> file.</a>

<!-- /HISTORY -->


<!-- CONTRIBUTE/ -->

<h2>Contribute</h2>

<a href="https://github.com/docpad/docpad-plugin-paged/blob/master/CONTRIBUTING.md#files">Discover how you can contribute by heading on over to the <code>CONTRIBUTING.md</code> file.</a>

<!-- /CONTRIBUTE -->


<!-- BACKERS/ -->

<h2>Backers</h2>

<h3>Maintainers</h3>

These amazing people are maintaining this project:

<ul><li><a href="http://www.delarre.net">Ben Delarre</a> — <a href="https://github.com/docpad/docpad-plugin-paged/commits?author=benjamind" title="View the GitHub contributions of Ben Delarre on repository docpad/docpad-plugin-paged">view contributions</a></li>
<li><a href="http://balupton.com">Benjamin Lupton</a> — <a href="https://github.com/docpad/docpad-plugin-paged/commits?author=balupton" title="View the GitHub contributions of Benjamin Lupton on repository docpad/docpad-plugin-paged">view contributions</a></li>
<li><a href="http://www.stormpoopersmith.com">Daniel Smith</a> — <a href="https://github.com/docpad/docpad-plugin-paged/commits?author=StormPooper" title="View the GitHub contributions of Daniel Smith on repository docpad/docpad-plugin-paged">view contributions</a></li></ul>

<h3>Sponsors</h3>

No sponsors yet! Will you be the first?

<span class="badge-patreon"><a href="https://patreon.com/bevry" title="Donate to this project using Patreon"><img src="https://img.shields.io/badge/patreon-donate-yellow.svg" alt="Patreon donate button" /></a></span>
<span class="badge-opencollective"><a href="https://opencollective.com/bevry" title="Donate to this project using Open Collective"><img src="https://img.shields.io/badge/open%20collective-donate-yellow.svg" alt="Open Collective donate button" /></a></span>
<span class="badge-gratipay"><a href="https://www.gratipay.com/bevry" title="Donate weekly to this project using Gratipay"><img src="https://img.shields.io/badge/gratipay-donate-yellow.svg" alt="Gratipay donate button" /></a></span>
<span class="badge-flattr"><a href="https://flattr.com/profile/balupton" title="Donate to this project using Flattr"><img src="https://img.shields.io/badge/flattr-donate-yellow.svg" alt="Flattr donate button" /></a></span>
<span class="badge-paypal"><a href="https://bevry.me/paypal" title="Donate to this project using Paypal"><img src="https://img.shields.io/badge/paypal-donate-yellow.svg" alt="PayPal donate button" /></a></span>
<span class="badge-bitcoin"><a href="https://bevry.me/bitcoin" title="Donate once-off to this project using Bitcoin"><img src="https://img.shields.io/badge/bitcoin-donate-yellow.svg" alt="Bitcoin donate button" /></a></span>
<span class="badge-wishlist"><a href="https://bevry.me/wishlist" title="Buy an item on our wishlist for us"><img src="https://img.shields.io/badge/wishlist-donate-yellow.svg" alt="Wishlist browse button" /></a></span>

<h3>Contributors</h3>

These amazing people have contributed code to this project:

<ul><li><a href="http://www.delarre.net">Ben Delarre</a> — <a href="https://github.com/docpad/docpad-plugin-paged/commits?author=benjamind" title="View the GitHub contributions of Ben Delarre on repository docpad/docpad-plugin-paged">view contributions</a></li>
<li><a href="http://balupton.com">Benjamin Lupton</a> — <a href="https://github.com/docpad/docpad-plugin-paged/commits?author=balupton" title="View the GitHub contributions of Benjamin Lupton on repository docpad/docpad-plugin-paged">view contributions</a></li>
<li><a href="http://www.stormpoopersmith.com">Daniel Smith</a> — <a href="https://github.com/docpad/docpad-plugin-paged/commits?author=StormPooper" title="View the GitHub contributions of Daniel Smith on repository docpad/docpad-plugin-paged">view contributions</a></li>
<li><a href="http://robloach.net">Rob Loach</a> — <a href="https://github.com/docpad/docpad-plugin-paged/commits?author=RobLoach" title="View the GitHub contributions of Rob Loach on repository docpad/docpad-plugin-paged">view contributions</a></li>
<li><a href="http://dcb.co.il">Daniel Cohen</a> — <a href="https://github.com/docpad/docpad-plugin-paged/commits?author=dcohenb" title="View the GitHub contributions of Daniel Cohen on repository docpad/docpad-plugin-paged">view contributions</a></li>
<li><a href="https://github.com/vsopvsop">vsopvsop</a> — <a href="https://github.com/docpad/docpad-plugin-paged/commits?author=vsopvsop" title="View the GitHub contributions of vsopvsop on repository docpad/docpad-plugin-paged">view contributions</a></li></ul>

<a href="https://github.com/docpad/docpad-plugin-paged/blob/master/CONTRIBUTING.md#files">Discover how you can contribute by heading on over to the <code>CONTRIBUTING.md</code> file.</a>

<!-- /BACKERS -->


<!-- LICENSE/ -->

<h2>License</h2>

Unless stated otherwise all works are:

<ul><li>Copyright &copy; 2012+ <a href="http://www.delarre.net">Ben Delarre</a></li></ul>

and licensed under:

<ul><li><a href="http://spdx.org/licenses/MIT.html">MIT License</a></li></ul>

<!-- /LICENSE -->
