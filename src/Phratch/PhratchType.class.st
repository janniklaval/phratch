Class {
	#name : #PhratchType,
	#superclass : #Object,
	#category : #'Phratch-Type'
}

{ #category : #'as yet unclassified' }
PhratchType >> attributes [
	
	<phratchType: #'Attributes'>
	^ AttributeArgMorph new choice: ''
]

{ #category : #'as yet unclassified' }
PhratchType >> boolean [
	
	<phratchType: #'Boolean'>
	^ BooleanArgMorph new
]

{ #category : #'as yet unclassified' }
PhratchType >> checkBox [
	
	<phratchType: #'CheckBox'>
	^ CheckBoxArgMorph new
]

{ #category : #'as yet unclassified' }
PhratchType >> color [
	
	<phratchType: #'Color'>
	^ ColorArgMorph new showPalette: true
]

{ #category : #'as yet unclassified' }
PhratchType >> colorVar [
	
	<phratchType: #'ColorVar'>
	^ ExpressionArgMorphWithMenu new 
		stringExpression: 'a color'; 
		menuSelector: #colorsMenu;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> constants [
	
	<phratchType: #'Constants'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #constantNames;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> costumes [
	
	<phratchType: #'Costumes'>
	^ ChoiceOrExpressionArgMorph new 
		getOptionsSelector: #costumeNames; 
		choice: 'costume1';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> directions [
	
	<phratchType: #'Directions'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '0'; 
		menuSelector: #directionMenu;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> drums [
	
	<phratchType: #'Drums'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '48'; 
		menuSelector: #midiDrumMenu;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> effects [
	
	<phratchType: #'Effects'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #graphicEffectNames; 
		choice: #color;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> event [
	
	<phratchType: #'Event'>
	^ EventTitleMorph new
]

{ #category : #'as yet unclassified' }
PhratchType >> instruments [
	
	<phratchType: #'Instruments'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '1'; 
		menuSelector: #midiInstrumentMenu;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> keys [
	
	<phratchType: #'Keys'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #keyNames; 
		choice: 'space';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> layoutStyles [
	
	<phratchType: #'LayoutStyles'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #layoutStyles; 
		choice: 'large';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> list [
	
	<phratchType: #'List'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #listVarMenu;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> listDelete [
	
	<phratchType: #'ListDelete'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '1'; 
		menuSelector: #listIndexForDeleteMenu;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> listIndex [
	
	<phratchType: #'ListIndex'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '1'; 
		menuSelector: #listIndexMenu;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> mathFunctions [
	
	<phratchType: #'MathFunctions'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #mathFunctionNames; 
		choice: #sqrt;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> namedColors [
	
	<phratchType: #'NamedColors'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #namedColors; 
		choice: #black;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> newCostume [
	
	<phratchType: #'NewCostume'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #newCostumeTypes; 
		choice: 'camera';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> notes [
	
	<phratchType: #'Notes'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '60'; 
		menuSelector: #noteSelector;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> number [
	
	<phratchType: #'Number'>
	^ ExpressionArgMorph new numExpression: '10'
]

{ #category : #'as yet unclassified' }
PhratchType >> sceneNames [
	
	<phratchType: #'SceneNames'>
	^ ChoiceOrExpressionArgMorph new 
		getOptionsSelector: #sceneNames; 
		choice: '';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> screenColor [
	
	<phratchType: #'ScreenColor'>
	^ ColorArgMorph new showPalette: false
]

{ #category : #'as yet unclassified' }
PhratchType >> soundNames [
	
	<phratchType: #'SoundNames'>
	^ ChoiceOrExpressionArgMorph new 
		getOptionsSelector: #soundNames; 
		choice: 'pop';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> sprite [
	
	<phratchType: #'Sprite'>
	^ SpriteArgMorph new
]

{ #category : #'as yet unclassified' }
PhratchType >> string [
	
	<phratchType: #'String'>
	^ ExpressionArgMorph new 
		stringExpression: '';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> timeDates [
	
	<phratchType: #'TimeDates'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #timeDates; 
		choice: 'time';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> variable [
	
	<phratchType: #'Variable'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #varNamesMenu; 
		choice: '';
		yourself
]
