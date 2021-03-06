Extension { #name : #ShadowDrawingCanvas }

{ #category : #'*Phratch-Extensions' }
ShadowDrawingCanvas >> contentsOfArea: aRectangle into: aForm [
	^myCanvas contentsOfArea: aRectangle into: aForm
]

{ #category : #'*Phratch-Extensions' }
ShadowDrawingCanvas >> copyClipRect: aRectangle [

^ myCanvas  copyClipRect: aRectangle
]

{ #category : #'*Phratch-Extensions' }
ShadowDrawingCanvas >> copyOffset: aPoint clipRect: sourceClip [

^ myCanvas  copyOffset: aPoint clipRect: sourceClip
]

{ #category : #'*Phratch-Extensions' }
ShadowDrawingCanvas >> grafPort [

	^myCanvas grafPort
]
