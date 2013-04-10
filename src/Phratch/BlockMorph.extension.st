Extension { #name : #BlockMorph }

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> addAreasOf: outerRect outside: innerRect color: col to: coll [

	coll addAll: (((outerRect areasOutside: innerRect) 
		collect: [:r | Array with: r with: col])
		reject: [:pair | ((pair first intersects: innerRect) 
					and: [(pair first right > innerRect left) 
					and: [(pair first left > innerRect left)
					and: [pair first top < innerRect bottom]]])
					or: [pair first left > innerRect right]])
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> addHLineFrom: startX to: endX y: yOffset color: c to: coll [

	| y |
	y := self top + yOffset.
	coll add: (Array
				with: ((self left + startX)@y corner: (self left + endX)@(y + 1))
				with: c)
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> addPoint: aPoint color: c to: coll [

	coll add: (Array 
				with: (self topLeft + aPoint extent: 1)
				with: c)

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> contrastColor [

	| ob |

	isContrasted := false.
	originalColor ifNotNil: [
		color := originalColor ].
	Contrast = #off ifTrue: [
		self isDeletedAttribute ifFalse: [
			^ self ]].
	self isDeletedAttribute 
		ifTrue: [^ color := color twiceLighter]
		ifFalse: [
			ob := self outerLoop.
			ob ifNil: [ 
				self isReporter
					ifTrue: [
						(owner isKindOf: MultiArgMorph)
							ifTrue: [ob := owner owner]
							ifFalse: [ob := owner]]
					ifFalse: [
						((owner isKindOf: ProcedureHatBlockMorph) and: [owner nextBlock ~= self])
							ifTrue: [ob := owner]]]].
	ob ifNil: [^ self ].
	ob color = color ifTrue: [
		originalColor := color.
		#slight = Contrast ifTrue: [ ^ color := color slightlyLighter ].
		#normal = Contrast ifTrue: [ ^ color := color lighter ].
		#strong = Contrast ifTrue: [
			isContrasted := true.
			color := color twiceLighter " lighter slightlyLighter "]].

	submorphs do: [:m | (m isKindOf: StringMorph)
		ifTrue: [m color: self labelColor ]
		ifFalse: [ (m isKindOf: MultiArgMorph)
			ifTrue: [m contrastColor]]].	


]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd OOP' }
BlockMorph >> disinheritAttribute [

	| sel rcv oi |
	(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isKindOf: ScriptablePhratchMorph) 
		ifFalse: [^ false].
	oi := rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ rcv undeleteAttribute: att]].
	^ false
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> drawInlinePaletteOn: aCanvas [
	^self
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd fast copying' }
BlockMorph >> fastCopy [

	"copies only the receiver without the nextBlock and its parts"

	| dict new |
	dict := IdentityDictionary new: 100.
	new := self fastCopyRecordingIn: dict.
	new allMorphsDo: [:m | m updateReferencesUsing: dict].
	^ new	
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd fast copying' }
BlockMorph >> fastCopyRecordingIn: dict [

	"copies just the receiver withoug the nextBlock and its parts"

	| new parts |
	new := self copy.
	dict at: self put: new.
	parts := self nonControlFlowSubmorphs.
	parts size > 0 ifTrue: [
		new privateSubmorphs:
			(parts collect: [:m |
				(m copyRecordingIn: dict) privateOwner: new])].

	self properties ifNotNil: [new privateProperties: self properties copyAll].
	^ new

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd fast copying' }
BlockMorph >> fastDuplicate [

	"for debugging"

	World activeHand attachMorph: self fastCopy.

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd OOP' }
BlockMorph >> inheritAttribute [

	| sel rcv oi |
	(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isKindOf: ScriptablePhratchMorph) 
		ifFalse: [^ false].
	oi := rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ rcv deleteAttribute: att]].
	^ false
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> isBlockTemplate [

	^ (self rootForGrabOf: self) ~= self
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> isCShape [

	^ false
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> isContrasted [
	^isContrasted ifNil: [isContrasted := false]
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> isContrasted: bool [
	isContrasted := bool
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd OOP' }
BlockMorph >> isCustomBlock [
	^false
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd OOP' }
BlockMorph >> isDeletedAttribute [

	| sel rcv oi |
	(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isKindOf: ScriptablePhratchMorph) 
		ifFalse: [^ false].

	((self isKindOf: VariableBlockMorph) 
	or: [self isKindOf: ListContentsBlockMorph]) ifTrue: [
		^ (rcv allVarNames includes: self commandSpec) not].

	self isCustomBlock ifTrue: [
		^ rcv inheritedBlockIds includes: self id].

	sel = #get: ifTrue: [
		 ^ rcv deletedAttributes includes: (self argumentAt: 1) choice].
		
	oi := rcv objectInterface.
	rcv deletedAttributes do: [:att |
		(oi at: att) second = sel ifTrue: [
			^ true]].
	^ false
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd OOP' }
BlockMorph >> isInheritableAttribute [
	"indicate if my context menu lets me delete my attribute"

	| sel rcv oi |
	(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph)
		ifNil: [^ false].
	(self respondsTo: #selector) ifFalse: [
		^ false].
	sel := self selector.
	(self respondsTo: #receiver) ifFalse: [
		^ false].
	rcv := self receiver.
	(rcv isKindOf: ScriptablePhratchMorph) 
		ifFalse: [^ false].
	rcv prototype ifNil: [
		^ false].
	oi := rcv objectInterface.
	oi keysDo: [:att |
		(oi at: att) second = sel ifTrue: [
			^ true]].
	^ false
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> isLambdaForm [
	^false
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> isNestedCShape [

	^ self outerLoop notNil

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> nests: aBlock [
	^ false
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> outerLoop [

	| all |
	all := self allOwners select: [:o | (o isKindOf: BlockMorph) and: [o notNil and: [o isCShape]]].
	all size < 1 ifTrue: [^ nil].
	^ all detect: [:o | o nests: self] ifNone: [nil]
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> pauseProcess [
	"Called on the top block of a running stack when all processes are stopped."

	phratchProc ifNotNil: [phratchProc pause].

]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd fast copying' }
BlockMorph >> privateProperties: collectionOfProperties [

	self setProperty: #properties toValue: collectionOfProperties
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd fast copying' }
BlockMorph >> properties [
	self valueOfProperty: #properties
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> refreshAttributeArgs [

	self allMorphsDo: [:m |
		(m isKindOf: AttributeArgMorph) ifTrue: [
			m refresh ]]
]

{ #category : #'*Phratch-BYOB-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd-ddddd lambdas' }
BlockMorph >> resumeProcess [
	"Called on the top block of a running stack when all processes are stopped."

	phratchProc ifNotNil: [phratchProc resume].

]
