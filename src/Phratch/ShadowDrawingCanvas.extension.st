Extension { #name : #ShadowDrawingCanvas }

{ #category : #'*Phratch-Extensions' }
ShadowDrawingCanvas >> contentsOfArea: aRectangle into: aForm [
	^myCanvas contentsOfArea: aRectangle into: aForm
]

{ #category : #'*Phratch-extensions' }
ShadowDrawingCanvas >> copyClipRect: aRectangle [

^ myCanvas  copyClipRect: aRectangle
]

{ #category : #'*Phratch-Extensions' }
ShadowDrawingCanvas >> grafPort [

	^myCanvas grafPort
]
