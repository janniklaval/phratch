Extension { #name : #NullTextStyler }

{ #category : #'*Phratch-Extensions' }
NullTextStyler >> attributesFor: aSymbol [	
	self deprecated: 'Not sent in 1.3'.
	^ nil
]

{ #category : #'*Phratch-Extensions' }
NullTextStyler >> monitor [
	self deprecated: 'Not sent in 1.3'.
	^Monitor new
]

{ #category : #'*Phratch-Extensions' }
NullTextStyler >> parseableSourceCodeTemplate [	
	self deprecated: 'Not sent in 1.3'.
	^'messageSelectorAndArgumentNames	
	"comment stating purpose of message"	
		
	| temporary variable names |
	statements'
]

{ #category : #'*Phratch-Extensions' }
NullTextStyler >> pixelHeight [	
	self deprecated: 'Not sent in 1.3'.
	^TextStyle defaultFont pixelSize
]

{ #category : #'*Phratch-Extensions' }
NullTextStyler >> privateFormat: aText [
	self deprecated: 'Not sent in 1.3'.
	^aText
]

{ #category : #'*Phratch-Extensions' }
NullTextStyler >> privateStyle: aText [
	self deprecated: 'Not sent in 1.3'.
	^aText
]

{ #category : #'*Phratch-Extensions' }
NullTextStyler >> styledTextFor: aText [
	"Assure that the text is black"
	self deprecated: 'Not sent in 1.3'.
	
	^aText
]

{ #category : #'*Phratch-Extensions' }
NullTextStyler >> terminateBackgroundStylingProcess [
	self deprecated: 'Not sent in 1.3'.

]
