Extension { #name : #PhratchType }

{ #category : #'*PhratchColor' }
PhratchType >> color [
	
	<phratchType: #'Color'>
	^ ColorArgMorph new showPalette: true
]

{ #category : #'*PhratchColor' }
PhratchType >> colorVar [
	
	<phratchType: #'ColorVar'>
	^ ExpressionArgMorphWithMenu new 
		stringExpression: 'a color'; 
		menuSelector: #colorsMenu;
		yourself
]

{ #category : #'*PhratchColor' }
PhratchType >> namedColors [
	
	<phratchType: #'NamedColors'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #namedColors; 
		choice: #black;
		yourself
]

{ #category : #'*PhratchColor' }
PhratchType >> screenColor [
	
	<phratchType: #'ScreenColor'>
	^ ColorArgMorph new showPalette: false
]
