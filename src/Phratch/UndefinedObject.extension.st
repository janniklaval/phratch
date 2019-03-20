Extension { #name : #UndefinedObject }

{ #category : #'*Phratch-extensions' }
UndefinedObject >> bitShift: aNumber [ 
	"change the receiver's sticky property"
	^ 0 bitShift: aNumber
]

{ #category : #'*Phratch-extensions' }
UndefinedObject >> sticky: aBoolean [ 
	"change the receiver's sticky property"
	^self
]
