# History

## v2.5.0 2017 April 20
- Updated base files

## v2.4.0 2015 March 1
- B/C Deprecated `@getPageUrl` template helper and replaced it with `@getPagedUrl`. Allows usage of both unless there is a clash with another plugin [issue #10](https://github.com/docpad/docpad-plugi-paged/issues/10)
- Prevent displaying URL compatibility warnings if compatibility is turned off in config

## v2.3.0 2015 February 27
    - Updated default URL structure (with backwards compatibility and configuration options)
        - Thanks to [Danny Smith](https://github.com/stormpooper) for [pull request #22](https://github.com/docpad/docpad-plugin-paged/pull/22), [Erv Walter](https://github.com/ervwalter) for [pull request #12](https://github.com/docpad/docpad-plugin-paged/pull/12)
    - Updated dependencies

## v2.2.5 2013 December 16
- DocPad v6.65 compatibility
- Updated dependencies

## v2.2.4 2013 December 16
- Added `getPageCollection(name)` template helper
- Updated dependencies

## v2.2.3 2013 October 26
- Updated dependencies

## v2.2.2 2013 July 28
- Degraded adding/added page messages to debug level

## v2.2.1 2013 July 27
- Better debugging messages
- More efficient algorithm when there are no pages
- Uses v6.46.4's new clone APIs to avoid duplicated events for our clone models

## v2.2.0 2013 July 2
- B/C Break: Streamlined the code by using the new DocPad v6.44.0 APIs
	- This version is incompatible with DocPad versions prior to v6.44
	- Documents are now injected into the DocPad database, this will now bring broader support for things, but it also means that your pages may show up in your content listing. Refer to the [README](https://github.com/docpad/docpad-plugin-paged) for instructions on how to avoid this.
- B/C Break: Document prototype extensions are now template helpers instead
	- You now do `@hasPage()` instead of `@getDocument().hasPage()`
- B/C Break: `pageSize` meta data attribute now defaults to `1` instead of `5`

## v2.1.6 2013 July 2
- Updated supported DocPad versions

## v2.1.5 2013 June 26
- Repackaged

## v2.1.4 2013 April 5
- Updated dependencies

## v2.1.3 2013 March 7
- Updated dependencies

## v2.1.2 2013 March 7
- Repackaged
- Updated dependencies

## v2.1.1 2013 February 8
- Switched repo to [Docpad organization](https://github.com/docpad/docpad-plugin-paged)

## v2.1.0 2013 Feburary 7
- Fixed [issue #2](https://github.com/docpad/docpad-plugin-paged/issues/1), now compatibile with cleanUrls plugin.

## v0.1.3 2012 December 2
- Minor code cleanup.

## v0.1.2 2012 December 2
- Emergency bug fix release.

## v0.1.1 2012 December 2
- Fixed unit tests so they now work, will document how to setup and run these in a blog post later and in the docpad documentation repo.

## v0.1.0 2012 November 30
- Initial working version for [Ben Delarre's Website](https://github.com/benjamind/delarre.net.docpad)
