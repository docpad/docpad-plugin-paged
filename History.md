## History

- v2.2.2 July 28, 2013
	- Degraded adding/added page messages to debug level

- v2.2.1 July 27, 2013
	- Better debugging messages
	- More efficient algorithm when there are no pages
	- Uses v6.46.4's new clone APIs to avoid duplicated events for our clone models

- v2.2.0 July 2, 2013
	- B/C Break: Streamlined the code by using the new DocPad v6.44.0 APIs
		- This version is incompatible with DocPad versions prior to v6.44
		- Documents are now injected into the DocPad database, this will now bring broader support for things, but it also means that your pages may show up in your content listing. Refer to the [README](https://github.com/docpad/docpad-plugin-paged) for instructions on how to avoid this.
	- B/C Break: Document prototype extensions are now template helpers instead
		- You now do `@hasPage()` instead of `@getDocument().hasPage()`
	- B/C Break: `pageSize` meta data attribute now defaults to `1` instead of `5`

- v2.1.6 July 2, 2013
	- Updated supported DocPad versions

- v2.1.5 June 26, 2013
	- Repackaged

- v2.1.4 April 5, 2013
	- Dependency upgrades

- v2.1.3 March 7, 2013
	- Dependency upgrades

- v2.1.2 March 7, 2013
	- Repackaged
	- Dependency upgrades
		-  `bal-util` from ~1.16.1 to ~1.16.8

- v2.1.1 February 8, 2013
	- Switched repo to [Docpad organization](https://github.com/docpad/docpad-plugin-paged)

- v2.1.0 Feburary 7, 2013
	- Fixed [issue #2](https://github.com/docpad/docpad-plugin-paged/issues/1), now compatibile with cleanUrls plugin.

- v0.1.3 December 2, 2012
	- Minor code cleanup.
	
- v0.1.2 December 2, 2012
	- Emergency bug fix release.

- v0.1.1 December 2, 2012
	- Fixed unit tests so they now work, will document how to setup and run these in a blog post later and in the docpad documentation repo.

- v0.1.0 November 30, 2012
	- Initial working version for [Ben Delarre's Website](https://github.com/benjamind/delarre.net.docpad)