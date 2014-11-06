Extension { #name : #Win32Platform }

{ #category : #'*Phratch' }
Win32Platform >> open: aUrl [ 

	NBWin32Shell shellOpen: aUrl asString
]
