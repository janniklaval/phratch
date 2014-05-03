Extension { #name : #PhratchType }

{ #category : #'*PhratchSound' }
PhratchType >> notes [
	
	<phratchType: #'Notes'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '60'; 
		menuSelector: #noteSelector;
		yourself
]
