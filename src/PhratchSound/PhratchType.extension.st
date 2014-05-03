Extension { #name : #PhratchType }

{ #category : #'*PhratchSound' }
PhratchType >> drums [
	
	<phratchType: #'Drums'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '48'; 
		menuSelector: #midiDrumMenu;
		yourself
]

{ #category : #'*PhratchSound' }
PhratchType >> instruments [
	
	<phratchType: #'Instruments'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '1'; 
		menuSelector: #midiInstrumentMenu;
		yourself
]

{ #category : #'*PhratchSound' }
PhratchType >> notes [
	
	<phratchType: #'Notes'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '60'; 
		menuSelector: #noteSelector;
		yourself
]
