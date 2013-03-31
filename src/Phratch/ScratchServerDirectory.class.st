"
I represent a virtual Scratch 'directory' that is actually stored on an HTTP server. A directory is actually a web page, where links from that page appear as subdirectories.

This is not meant to be used with on arbitrary web pages. Instead, it's meant to view a repository of Scratch projects structured like a folder hierarchy.

"
Class {
	#name : #ScratchServerDirectory,
	#superclass : #Object,
	#instVars : [
		'serverName',
		'path',
		'fetcher'
	],
	#category : #'Phratch-UI-Support'
}

{ #category : #accessing }
ScratchServerDirectory >> allNames [
	"If the last fetch completed successfully, answer an array of all my entry names. Otherwise, answer an empty array."

	| allNames |
	self fetchSucceeded ifFalse: [^ #()].

	allNames := (HtmlChunker linksFrom: fetcher bodyData asString) asArray
		collect: [:assoc | assoc value replaceHtmlHexChars].

	allNames := allNames select: [:s | s size > 0 and: [s first ~= $/]].  "eliminate parent folder links"
	allNames := allNames select: [:s | ((s includes: $=) | (s includes: $;)) not].  "eliminate Apache sorting links"

	allNames := allNames collect: [:s |
		((s size > 1) and: [s last = $/])
			ifTrue: [s copyFrom: 1 to: s size - 1]
			ifFalse: [s]].  "remove trailing '/' characters"

	allNames sort: [:s1 :s2 | s1 caseInsensitiveLessOrEqual: s2].

	^ allNames 


]

{ #category : #accessing }
ScratchServerDirectory >> directoryNamed: aString [
	"Answer a new ServerDirectory on the given subdirectory of my current path. In HTML terms, a subdirectory is a link from the current page."

	| newPath |
	fetcher ifNotNil: [fetcher stopDownload. fetcher := nil].

	newPath := aString.
	(newPath endsWith: '/') ifFalse: [newPath := newPath, '/'].

	newPath first = $/ ifTrue: [^ self copy path: newPath].  "absolute path"

	"relative path"
	newPath := path last = $/ ifTrue: [path, aString] ifFalse: [path, '/', aString].
	(newPath endsWith: '/') ifFalse: [newPath := newPath, '/'].

	^ self copy path: newPath

]

{ #category : #fetching }
ScratchServerDirectory >> fetchFailureReason [
	"Answer the reason for the fetch failure. Answer the empty string if there has not been a failure." 

	fetcher ifNil: [^ ''].
	^ fetcher failureReason

]

{ #category : #fetching }
ScratchServerDirectory >> fetchInProgress [
	"Answer true if my contents is still being fetched. If a fetch has not yet been started, start one."
	"Note: When this method answer's true, the client should first make sure that the fetch succeeded using fetchSucceeded. If it did, then directoryNames and projectNames can be called to access the directory contents."

	fetcher ifNil: [
		fetcher := HTTPFetcher new.
		fetcher startDownload: path fromServer: serverName].

	^ fetcher inProgress

]

{ #category : #fetching }
ScratchServerDirectory >> fetchSucceeded [
	"Answer true if fetching my contents was successful." 

	fetcher ifNil: [^ false].
	^ fetcher succeeded

]

{ #category : #accessing }
ScratchServerDirectory >> parentDirectory [
	"Answer a new ServerDirectory on the parent of my current path."

	| newPath parts |
	fetcher ifNotNil: [fetcher stopDownload. fetcher := nil].

	newPath := ''.
	parts := path findTokens: '/'.
	1 to: parts size - 1 do: [:i |
		newPath := newPath, '/', (parts at: i)].
	((newPath size = 0) or: [newPath last ~= $/]) ifTrue: [newPath := newPath, '/'].

	^ self copy path: newPath

]

{ #category : #accessing }
ScratchServerDirectory >> path [

	^ path

]

{ #category : #accessing }
ScratchServerDirectory >> path: aString [
	"Set my path to the given string."

	fetcher ifNotNil: [fetcher stopDownload. fetcher := nil].
	path := aString.

]

{ #category : #accessing }
ScratchServerDirectory >> pathNameDelimiter [

	^ $/

]

{ #category : #accessing }
ScratchServerDirectory >> pathParts [
	"Answer my path as an array of directory names."

	^ (path findTokens: '/') asArray

]

{ #category : #accessing }
ScratchServerDirectory >> serverName [

	^ serverName

]

{ #category : #accessing }
ScratchServerDirectory >> serverName: aString [
	"Set my server name to the given string (e.g. 'web.media.mit.edu')."

	serverName := aString.

]

{ #category : #accessing }
ScratchServerDirectory >> stopFetching [
	"Stop the fetch that is in progress. Do nothing if a fetch is not in progress."

	fetcher ifNotNil: [
		fetcher stopDownload.
		fetcher := nil].


]
