Class {
	#name : #PhratchCategoryPen,
	#superclass : #PhratchCategory,
	#category : #PhratchPen
}

{ #category : #accessing }
PhratchCategoryPen class >> color [
	^(Color h: 165 s: 1 v: 0.63)
]

{ #category : #accessing }
PhratchCategoryPen class >> label [
	^'pen'
]

{ #category : #accessing }
PhratchCategoryPen class >> objectInterface [

	^ 
	{	"attribute					category		getter				setter				menu string			inheritable"
		#penDown			->	#(	pen				penDown			penDown:			'pen down?'			+			).
		#penColor			->	#(	pen				penHue				setPenHueTo:		'pen color'			+			).
		#penShade			->	#(	pen				penShade			setPenShadeTo:		'pen shade'			+			).
		#penSize			->	#(	pen				penSize				penSize:				'pen size'			+			).
	} asDictionary
]

{ #category : #accessing }
PhratchCategoryPen class >> order [
	^7
]
