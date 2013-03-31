"
I represent a scriptable scratch morph argument for a command block.  Clicking on me and then another point on the screen allows the user to set my value to the scriptable scratch morph that has been clicked on.
"
Class {
	#name : #SpriteArgMorph,
	#superclass : #ArgMorph,
	#instVars : [
		'menuIconMorph',
		'morph'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #other }
SpriteArgMorph >> acceptsDroppedReporters [

	^ true

]

{ #category : #other }
SpriteArgMorph >> acceptsTypeOf: aBlockMorph [
	"Answer true if I can accept a dropped reporter of the given type."

	aBlockMorph isReporter ifFalse: [^ false].
	^ aBlockMorph isBooleanReporter not

]

{ #category : #other }
SpriteArgMorph >> checkForDeletedMorph [
	"If I refer to a Sprite that has been deleted, nil out my morph field. Do nothing if my morph is a ScratchStageMorph"

	(morph isKindOf: Morph) ifFalse: [^ self].
	morph owner ifNotNil: [^ self].

	(morph isKindOf: ScratchStageMorph) ifTrue: [^ self].

	morph := nil.  "nil out reference to deleted sprite"


]

{ #category : #other }
SpriteArgMorph >> clearMorphReference [
	"Clear my morph reference."

	(morph isKindOf: Morph) ifFalse: [^ self].
	morph := nil.
	self updateLabel.

]

{ #category : #other }
SpriteArgMorph >> defaultValue: aSpriteMorph [

	morph := aSpriteMorph.

]

{ #category : #other }
SpriteArgMorph >> evaluate [
	"Answer either nil, the symbols #mouse or #myself, or a Scratch sprite object."

	morph = #null ifTrue: [
		^ nil ].

	morph = #myself ifTrue: [
		^owner receiver ].

	morph = #allSprites ifTrue: [
		^owner receiver allSprites].

" ------------ moved to ArgMorph ---------------

	morph = 'my owner' ifTrue: [
		^owner receiver ownerSprite ].
	morph = 'my parts' ifTrue: [
		^ScratchListMorph on: owner receiver subsprites].
	morph = 'my prototype' ifTrue: [
		^owner receiver prototype ].
	morph = 'my name' ifTrue: [
		^owner receiver objName ].

--------------------------------------------------------"

	morph = #nothing ifTrue: [
		^nil ].
	self checkForDeletedMorph.
	^ morph

]

{ #category : #'object i/o' }
SpriteArgMorph >> fieldsVersion [

	^ 1

]

{ #category : #other }
SpriteArgMorph >> fixArgLayout [
	"Set my color to my owner's color."

	self color: (owner color mixed: 0.7 with: (Color gray: 0.3)).

]

{ #category : #'event handling' }
SpriteArgMorph >> fixGetAttribueBlock [
	"If my owner is a get attribute block, make sure that the attribute is consistent the the type of the target sprite or stage."

	| attributeArg possibleAttributes |
	morph = #null ifTrue: [^ self].
	morph ifNil: [^ self].
	((owner isKindOf: ReporterBlockMorph) and: [owner selector = #getAttribute:of:]) ifFalse: [^ self].

	attributeArg := owner submorphs detect: [:m | m isKindOf: AttributeArgMorph] ifNone: [^ self].

	possibleAttributes := morph attributeNames, morph varNames.
	(possibleAttributes includes: attributeArg choice) ifFalse: [
		 attributeArg choice: possibleAttributes first].

]

{ #category : #BYOB }
SpriteArgMorph >> getChoice [
	morph = #null 
		ifTrue: [^ #null].
	morph = #myself 
		ifTrue: [^ #myself].
	morph = #allSprites 
		ifTrue: [^ #allSprites].
	^ self evaluate
]

{ #category : #'event handling' }
SpriteArgMorph >> handlesMouseDown: evt [

	^ evt hand toolType isNil and:
		[(self topRight - (14@0) corner: self bottomRight) containsPoint: evt cursorPoint]

]

{ #category : #other }
SpriteArgMorph >> implicitValue: anObject [

	implicitValue := anObject.
	morph := anObject
]

{ #category : #'object i/o' }
SpriteArgMorph >> initFieldsFrom: anObjStream version: classVersion [

	super initFieldsFrom: anObjStream version: classVersion.
	self initFieldsNamed: #(
		morph
	) from: anObjStream.

]

{ #category : #initialize }
SpriteArgMorph >> initialize [

	super initialize.
	self borderInset.
	self borderWidth: 1.
	self color: Color white.

	labelMorph := ScratchStringMorph new
		font: (ScratchFrameMorph getFont: #Arg);
		forceUnicodeRendering: true;
		color: Color white.
	self addMorph: labelMorph.
	((labelMorph extent y) > 15)
		ifTrue: [ self extent: 20@((labelMorph extent y) + 3) ]
		ifFalse: [ self extent: 20@15 ].
	menuIconMorph := ImageMorph new form: DropDownMenuForm.
	self addMorphFront: menuIconMorph.

	morph := nil.
	self updateLabel.

]

{ #category : #BYOB }
SpriteArgMorph >> isEmptySlot [
	^morph = #null
]

{ #category : #'event handling' }
SpriteArgMorph >> mouseDown: evt [

	self presentMenu.

]

{ #category : #'event handling' }
SpriteArgMorph >> presentMenu [
	"Let the user select a Scratch object or the special value #mouse."

	| frame sel objList menu choice be |

	(frame := self ownerOrYourselfThatIsA: ScratchFrameMorph) ifNil: [
		be := self ownerOrYourselfThatIsA: BlockEditorFrameMorph.
		be ifNil: [^self].
		(frame := be scratchFrame) ifNil: [^ self]].

	(owner isKindOf: CommandBlockMorph) ifTrue: [sel := owner selector].

	objList := frame scratchObjects.
	objList sort: [:obj1 :obj2 | obj1 objName asLowercase < obj2 objName asLowercase].

	menu := MenuMorph new.

"	menu add: '' action: #null.
"
	(#(getAttribute:of: getObject: attribute:of:) includes: sel) ifTrue: [
		menu add: 'Stage' localized
				target: self
				selector: #selectedItem:
				argument: frame workPane].

	(#(stickTo:) includes: sel) ifTrue: [
		menu add: 'nothing' localized
				target: self
				selector: #selectedItem:
				argument: #nothing].

	(#("getAttribute:of:" attribute:of: getObject: getSpawnOf: deleteSprite:) includes: sel) ifTrue: [
		menu add: 'myself' localized
				target: self
				selector: #selectedItem:
				argument: #myself].

	(#(getObject: ) includes: sel) ifTrue: [
		menu add: 'all sprites' localized
				target: self
				selector: #selectedItem:
				argument: #allSprites].

" --- on second thought I moved the following options to the ArgMorph's menu ----------------------

	relatives := OrderedCollection new.
	#getObject: = sel ifTrue: [
		relatives add: 'my name'].
	relatives
		add: 'my prototype';
		add: 'my owner'.
	#getObject: = sel ifTrue: [
		relatives add: 'my parts'].
	menu addLine.
	relatives do: [:sym | menu add: sym action: sym].
 ----------------------------------------------------------------------------------------------------------------- "

	(#(getAttribute:of: getObject: getSpawnOf: deleteSprite: attribute:of: stickTo: deleteObject:) includes: sel)
		ifFalse: [
			menu add: 'mouse-pointer' localized
				target: self
				selector: #selectedItem:
				argument: #mouse.
			sel = #touching: ifTrue: [
				menu add: 'edge' localized
				target: self
				selector: #selectedItem:
				argument: #edge].
			objList := objList copyWithout: owner receiver].

	objList size > 0 ifTrue: [menu addLine].
	objList do: [:obj | menu add: obj objName
		target: self
		selector: #selectedItem:
		argument: obj].

	(choice := menu invokeModal) ifNil: [^ self].
	morph := choice.
	self fixGetAttribueBlock.
	self updateLabel.

]

{ #category : #other }
SpriteArgMorph >> printArgOn: aStream [
	"Print this argument morph on the given stream."

	aStream nextPutAll: 's['.
	aStream nextPutAll: self labelMorph contents.
	aStream nextPut: $].

]

{ #category : #stepping }
SpriteArgMorph >> selectedItem: anItem [
	morph := anItem
]

{ #category : #stepping }
SpriteArgMorph >> step [

	self updateLabel.

]

{ #category : #stepping }
SpriteArgMorph >> stepTime [

	^ 500

]

{ #category : #'object i/o' }
SpriteArgMorph >> storeFieldsOn: anObjStream [

	super storeFieldsOn: anObjStream.
	self storeFieldsNamed: #(
		morph
	) on: anObjStream.

]

{ #category : #stepping }
SpriteArgMorph >> updateLabel [
	"Update my label string."

	| s |
	self checkForDeletedMorph.
	s := ' '.
	(morph isKindOf: ScriptableScratchMorph) ifTrue: [s := morph objName].
	(morph isKindOf: String) ifTrue: [
		s := morph localized.
		morph = #mouse ifTrue: [s := 'mouse-pointer' localized].
		morph = #null ifTrue: [s := '']].

	labelMorph contents = s ifFalse: [
		labelMorph contents: s.
		labelMorph position: self position + borderWidth + (3 @ -1).
		self extent: (labelMorph extent + (16@2) + borderWidth).
		menuIconMorph position: (self right - borderWidth - 10)@(self top + borderWidth + 4).
		(self owner isKindOf: BlockMorph) ifTrue: [
			self owner addLabel].
		(self ownerOrYourselfThatIsA: ScratchBlockPaletteMorph) ifNotNil: [
			(self ownerOrYourselfThatIsA: ScratchBlockPaletteMorph) fixLayout]].

]

{ #category : #copy }
SpriteArgMorph >> veryDeepFixupWith: deepCopier [
	"If fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals."

	super veryDeepFixupWith: deepCopier.
	morph := deepCopier references at: morph ifAbsent: [morph].
]

{ #category : #copy }
SpriteArgMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

	super veryDeepInner: deepCopier.
	menuIconMorph := menuIconMorph veryDeepCopyWith: deepCopier.

]

{ #category : #'event handling' }
SpriteArgMorph >> wantsKeyboardFocusFor: aSubmorph [
	"Don't allow shift-click editing of block labels."

	^ false

]
