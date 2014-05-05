Extension { #name : #PhratchType }

{ #category : #'*PhratchList' }
PhratchType >> listIndex [
	
	<phratchType: #'ListIndex'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '1'; 
		menuSelector: #listIndexMenu;
		yourself
]
