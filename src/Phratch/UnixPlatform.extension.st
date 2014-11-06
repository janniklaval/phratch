Extension { #name : #UnixPlatform }

{ #category : #'*Phratch' }
UnixPlatform >> open: aUrl [ 

	NBUnixShell shellOpen: aUrl asString
]
