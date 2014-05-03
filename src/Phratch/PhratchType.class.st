Class {
	#name : #PhratchType,
	#superclass : #Object,
	#instVars : [
		'receiver'
	],
	#category : #'Phratch-Type'
}

{ #category : #'as yet unclassified' }
PhratchType >> attributes [
	
	<phratchType: #'Attributes'>
	^ AttributeArgMorph new choice: ''
]

{ #category : #'as yet unclassified' }
PhratchType >> blockId [
	
	<phratchType: #'BlockId'>
	^ ChoiceArgMorph new getOptionsSelector: #blockId; choice: '';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> boolean [
	
	<phratchType: #'Boolean'>
	^ BooleanArgMorph new
]

{ #category : #'as yet unclassified' }
PhratchType >> cArgSlot [
	
	<phratchType: #'CArgSlot'>
	 ^ CArgSlotMorph new
]

{ #category : #'as yet unclassified' }
PhratchType >> cSlot [
	
	<phratchType: #'CSlot'>
	^ CSlotMorph new "SpecialArgMorph new type: #command"
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
PhratchType >> input [
	
	<phratchType: #'Input'>
	 ^ ChoiceArgMorph new options: {'with inputs' localized. 'with input list' localized}; choice: 'with inputs';
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
PhratchType >> loop [
	
	<phratchType: #'Loop'>
	^ MultiArgMorph type: #loop
]

{ #category : #'as yet unclassified' }
PhratchType >> mAAny [
	
	<phratchType: #'MAAny'>
	^ MultiArgMorph type: #any
]

{ #category : #'as yet unclassified' }
PhratchType >> mABoolean [
	
	<phratchType: #'MABoolean'>
	^ MultiArgMorph type: #boolean
]

{ #category : #'as yet unclassified' }
PhratchType >> mACommand [
	
	<phratchType: #'MACommand'>
	^ MultiArgMorph type: #command
]

{ #category : #'as yet unclassified' }
PhratchType >> mAList [
	
	<phratchType: #'MAList'>
	^ MultiArgMorph type: #list
]

{ #category : #'as yet unclassified' }
PhratchType >> mANumber [
	
	<phratchType: #'MANumber'>
	^ MultiArgMorph type: #number
]

{ #category : #'as yet unclassified' }
PhratchType >> mAObjS [
	
	<phratchType: #'MAObjS'>
	^ MultiArgMorph type: #objSlot
]

{ #category : #'as yet unclassified' }
PhratchType >> mAPredicate [
	
	<phratchType: #'MAPredicate'>
	^ MultiArgMorph type: #predicate
]

{ #category : #'as yet unclassified' }
PhratchType >> mAReporter [
	
	<phratchType: #'MAReporter'>
	^ MultiArgMorph type: #reporter
]

{ #category : #'as yet unclassified' }
PhratchType >> mAText [
	
	<phratchType: #'MAText'>
	^ MultiArgMorph type: #text
]

{ #category : #'as yet unclassified' }
PhratchType >> mAUnEBool [
	
	<phratchType: #'MAUnEBool'>
	^ MultiArgMorph type: #unevaluatedBoolean
]

{ #category : #'as yet unclassified' }
PhratchType >> mAUneval [
	
	<phratchType: #'MAUneval'>
	^ MultiArgMorph type: #unevaluated
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
PhratchType >> number [
	
	<phratchType: #'Number'>
	^ ExpressionArgMorph new numExpression: '10'
]

{ #category : #'as yet unclassified' }
PhratchType >> oSBoolean [
	
	<phratchType: #'OSBoolean'>
	^ OSlotMorph new receiver: receiver; type: #booleanslot; yourself "SpecialArgMorph new type: #predicate"
]

{ #category : #'as yet unclassified' }
PhratchType >> oSReporter [
	
	<phratchType: #'OSReporter'>
	^ OSlotMorph new receiver: receiver; type: #reporterslot; yourself "SpecialArgMorph new type: #reporter"
]

{ #category : #accessing }
PhratchType >> receiver [
	^ receiver
]

{ #category : #accessing }
PhratchType >> receiver: anObject [
	receiver := anObject
]

{ #category : #'as yet unclassified' }
PhratchType >> rotation [
	
	<phratchType: #'Rotation'>
	^ ChoiceArgMorph new getOptionsSelector: #rotationStyleChanger; choice: 'normal';
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> sABoolean [
	
	<phratchType: #'SABoolean'>
	^ SpecialArgMorph new type: #booleanslot;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> sAList [
	
	<phratchType: #'SAList'>
	^ SpecialArgMorph new type: #list;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> sAObjS [
	
	<phratchType: #'SAObjS'>
	^ SpecialArgMorph new type: #objSlot
]

{ #category : #'as yet unclassified' }
PhratchType >> sAReporter [
	
	<phratchType: #'SAReporter'>
	 ^ SpecialArgMorph new type: #reporterslot;
		yourself
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
PhratchType >> specialVar [
	
	<phratchType: #'SpecialVar'>
	^ VariableBlockMorph new 
							isSpecialForm: true; 
							selector: #getVar:;
							commandSpec: '?';
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
PhratchType >> text [
	
	<phratchType: #'Text'>
	 ^ ExpressionArgMorph new stringExpression: ''; isText: true;
		yourself.  "SpecialArgMorph new type: #text"
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
PhratchType >> type [
	
	<phratchType: #'Type'>
	^ ChoiceArgMorph new options: {'number' localized. 'text' localized. 'boolean' localized. 'list' localized. 'command' localized. 'reporter' localized. 'predicate' localized. 'object' localized}; choice: 'number' localized;
		yourself
]

{ #category : #'as yet unclassified' }
PhratchType >> unEBool [
	
	<phratchType: #'UnEBool'>
	^ UnevaluatedBooleanArgMorph new
]

{ #category : #'as yet unclassified' }
PhratchType >> unEExp [
	
	<phratchType: #'UnEExp'>
	^ UnevaluatedExpressionArgMorph new stringExpression: ''
]

{ #category : #'as yet unclassified' }
PhratchType >> variable [
	
	<phratchType: #'Variable'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #varNamesMenu; 
		choice: '';
		yourself
]
