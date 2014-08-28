Class {
	#name : #PhratchType,
	#superclass : #Object,
	#instVars : [
		'receiver'
	],
	#category : #'Phratch-Type'
}

{ #category : #accessing }
PhratchType >> any [
	
	<phratchType: #'Any'>
		 ^ SpecialArgMorph new type: #any;
		yourself
]

{ #category : #accessing }
PhratchType >> array [
	
	<phratchType: #'Array'>
		 ^ SpecialArgMorph new type: #any;
		yourself
]

{ #category : #accessing }
PhratchType >> attributes [
	
	<phratchType: #'Attributes'>
	^ AttributeArgMorph new choice: ''
]

{ #category : #types }
PhratchType >> blockId [
	
	<phratchType: #'BlockId'>
	^ ChoiceArgMorph new getOptionsSelector: #blockId; choice: '';
		yourself
]

{ #category : #acessing }
PhratchType >> boolean [
	
	<phratchType: #'Boolean'>
	^ BooleanArgMorph new
]

{ #category : #types }
PhratchType >> cArgSlot [
	
	<phratchType: #'CArgSlot'>
	 ^ CArgSlotMorph new
]

{ #category : #types }
PhratchType >> cSlot [
	
	<phratchType: #'CSlot'>
	^ CSlotMorph new "SpecialArgMorph new type: #command"
]

{ #category : #'instance creation' }
PhratchType >> checkBox [
	
	<phratchType: #'CheckBox'>
	^ CheckBoxArgMorph new
]

{ #category : #types }
PhratchType >> constants [
	
	<phratchType: #'Constants'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #constantNames;
		yourself
]

{ #category : #'BYOB attributes' }
PhratchType >> costumes [
	
	<phratchType: #'Costumes'>
	^ ChoiceOrExpressionArgMorph new 
		getOptionsSelector: #costumeNames; 
		choice: 'costume1';
		yourself
]

{ #category : #types }
PhratchType >> directions [
	
	<phratchType: #'Directions'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '0'; 
		menuSelector: #directionMenu;
		yourself
]

{ #category : #types }
PhratchType >> effects [
	
	<phratchType: #'Effects'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #graphicEffectNames; 
		choice: #color;
		yourself
]

{ #category : #accessing }
PhratchType >> event [
	
	<phratchType: #'Event'>
	^ EventTitleMorph new
]

{ #category : #accessing }
PhratchType >> input [
	
	<phratchType: #'Input'>
	 ^ ChoiceArgMorph new options: {'with inputs' localized. 'with input list' localized}; choice: 'with inputs';
		yourself
]

{ #category : #accessing }
PhratchType >> keys [
	
	<phratchType: #'Keys'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #keyNames; 
		choice: 'space';
		yourself
]

{ #category : #'panther actions' }
PhratchType >> layoutStyles [
	
	<phratchType: #'LayoutStyles'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #layoutStyles; 
		choice: 'large';
		yourself
]

{ #category : #accessing }
PhratchType >> list [
	
	<phratchType: #'List'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #listVarMenu;
		yourself
]

{ #category : #types }
PhratchType >> listDelete [
	
	<phratchType: #'ListDelete'>
	^ ExpressionArgMorphWithMenu new 
		numExpression: '1'; 
		menuSelector: #listIndexForDeleteMenu;
		yourself
]

{ #category : #types }
PhratchType >> loop [
	
	<phratchType: #'Loop'>
	^ MultiArgMorph type: #loop
]

{ #category : #types }
PhratchType >> mAAny [
	
	<phratchType: #'MAAny'>
	^ MultiArgMorph type: #any
]

{ #category : #types }
PhratchType >> mABoolean [
	
	<phratchType: #'MABoolean'>
	^ MultiArgMorph type: #boolean
]

{ #category : #types }
PhratchType >> mACommand [
	
	<phratchType: #'MACommand'>
	^ MultiArgMorph type: #command
]

{ #category : #types }
PhratchType >> mAList [
	
	<phratchType: #'MAList'>
	^ MultiArgMorph type: #list
]

{ #category : #types }
PhratchType >> mANumber [
	
	<phratchType: #'MANumber'>
	^ MultiArgMorph type: #number
]

{ #category : #types }
PhratchType >> mAObjS [
	
	<phratchType: #'MAObjS'>
	^ MultiArgMorph type: #objSlot
]

{ #category : #types }
PhratchType >> mAPredicate [
	
	<phratchType: #'MAPredicate'>
	^ MultiArgMorph type: #predicate
]

{ #category : #types }
PhratchType >> mAReporter [
	
	<phratchType: #'MAReporter'>
	^ MultiArgMorph type: #reporter
]

{ #category : #types }
PhratchType >> mAText [
	
	<phratchType: #'MAText'>
	^ MultiArgMorph type: #text
]

{ #category : #types }
PhratchType >> mAUnEBool [
	
	<phratchType: #'MAUnEBool'>
	^ MultiArgMorph type: #unevaluatedBoolean
]

{ #category : #types }
PhratchType >> mAUneval [
	
	<phratchType: #'MAUneval'>
	^ MultiArgMorph type: #unevaluated
]

{ #category : #types }
PhratchType >> mathFunctions [
	
	<phratchType: #'MathFunctions'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #mathFunctionNames; 
		choice: #sqrt;
		yourself
]

{ #category : #'instance creation' }
PhratchType >> newCostume [
	
	<phratchType: #'NewCostume'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #newCostumeTypes; 
		choice: 'camera';
		yourself
]

{ #category : #accessing }
PhratchType >> number [
	
	<phratchType: #'Number'>
	^ ExpressionArgMorph new numExpression: '10'
]

{ #category : #types }
PhratchType >> oSBoolean [
	
	<phratchType: #'OSBoolean'>
	^ OSlotMorph new receiver: receiver; type: #booleanslot; yourself "SpecialArgMorph new type: #predicate"
]

{ #category : #types }
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

{ #category : #types }
PhratchType >> rotation [
	
	<phratchType: #'Rotation'>
	^ ChoiceArgMorph new getOptionsSelector: #rotationStyleChanger; choice: 'normal';
		yourself
]

{ #category : #types }
PhratchType >> sABoolean [
	
	<phratchType: #'SABoolean'>
	^ SpecialArgMorph new type: #booleanslot;
		yourself
]

{ #category : #types }
PhratchType >> sAList [
	
	<phratchType: #'SAList'>
	^ SpecialArgMorph new type: #list;
		yourself
]

{ #category : #types }
PhratchType >> sAObjS [
	
	<phratchType: #'SAObjS'>
	^ SpecialArgMorph new type: #objSlot
]

{ #category : #types }
PhratchType >> sAReporter [
	
	<phratchType: #'SAReporter'>
	 ^ SpecialArgMorph new type: #reporterslot;
		yourself
]

{ #category : #'looks ops' }
PhratchType >> sceneNames [
	
	<phratchType: #'SceneNames'>
	^ ChoiceOrExpressionArgMorph new 
		getOptionsSelector: #sceneNames; 
		choice: '';
		yourself
]

{ #category : #types }
PhratchType >> specialVar [
	
	<phratchType: #'SpecialVar'>
	^ VariableBlockMorph new 
							isSpecialForm: true; 
							selector: #getVar:;
							commandSpec: '?';
		yourself
]

{ #category : #public }
PhratchType >> sprite [
	
	<phratchType: #'Sprite'>
	^ SpriteArgMorph new
]

{ #category : #accessing }
PhratchType >> string [
	
	<phratchType: #'String'>
	^ ExpressionArgMorph new 
		stringExpression: '';
		yourself
]

{ #category : #accessing }
PhratchType >> text [
	
	<phratchType: #'Text'>
	 ^ ExpressionArgMorph new stringExpression: ''; isText: true;
		yourself.  "SpecialArgMorph new type: #text"
]

{ #category : #'panther actions' }
PhratchType >> timeDates [
	
	<phratchType: #'TimeDates'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #timeDates; 
		choice: 'time';
		yourself
]

{ #category : #accessing }
PhratchType >> type [
	
	<phratchType: #'Type'>
	^ ChoiceArgMorph new options: {'number' localized. 'text' localized. 'boolean' localized. 'list' localized. 'command' localized. 'reporter' localized. 'predicate' localized. 'object' localized}; choice: 'number' localized;
		yourself
]

{ #category : #types }
PhratchType >> unEBool [
	
	<phratchType: #'UnEBool'>
	^ UnevaluatedBooleanArgMorph new
]

{ #category : #types }
PhratchType >> unEExp [
	
	<phratchType: #'UnEExp'>
	^ UnevaluatedExpressionArgMorph new stringExpression: ''
]

{ #category : #accessing }
PhratchType >> variable [
	
	<phratchType: #'Variable'>
	^ ChoiceArgMorph new 
		getOptionsSelector: #varNamesMenu; 
		choice: '';
		yourself
]
