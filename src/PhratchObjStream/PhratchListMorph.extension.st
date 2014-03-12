Extension { #name : #PhratchListMorph }

{ #category : #'*PhratchObjStream' }
PhratchListMorph >> complexContents: anArray [

	| obj |
	1 to: anArray size do: [:i |
		obj := anArray at: i.
		obj isNil ifFalse: [
			self setLineAt: i to: obj]].
	anArray isEmpty ifFalse: [ self noteChangeAtIndex: 1 ]
]

{ #category : #'*PhratchObjStream' }
PhratchListMorph >> convertBlockTuplesToStacksFor: aScriptablePhratchMorph [

	"only for multi arg persistence"
	| obj block |

	cellMorphs do: [:m | obj := m complexObject.

		(obj isKindOf: Array) ifTrue: [

			#block = obj first ifTrue: [
				block := aScriptablePhratchMorph stackFromTupleList: obj third receiver: aScriptablePhratchMorph.
				m complexObject: block ]]].

	self updateContents
]

{ #category : #'*PhratchObjStream' }
PhratchListMorph >> convertStacksToTuples [
	"format conventions:

		block: 
					1 - #block
					2 - receiver
					3 - tupleSequence

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"

	| obj rcvr ref |
	cellMorphs
		do: [ :m | 
			obj := m complexObject.
			(obj isKindOf: BlockMorph)
				ifTrue: [ 
					rcvr := (obj receiver isKindOf: ScriptablePhratchMorph)
						ifTrue: [ 
							(obj receiver isKindOf: PhratchStageMorph)
								ifTrue: [ 'Stage' ]
								ifFalse: [ obj receiver objName ] ]
						ifFalse: [ '' ].
					m complexObject: (Array with: #block with: rcvr with: obj tupleSequence) ].
			(obj isKindOf: self class)
				ifTrue: [ 
					ref := obj asReferenceTuple.
					ref isNil
						ifTrue: [ obj convertStacksToTuples ]
						ifFalse: [ m complexObject: ref ] ].
			(obj isKindOf: ScriptablePhratchMorph)
				ifTrue: [ 
					ref := obj asReferenceTuple.
					m complexObject: ref ] ]
]

{ #category : #'*PhratchObjStream' }
PhratchListMorph >> convertTuplesToStacks [
	"format conventions:

		sprite:
					1 - #sprite
					2 - name

		stage:		#stage

		block: 
					1 - #block
					2 - receiver
					3 - tupleSequence

		named list reference:

					1 - #namedList
					2 - target obj name
					3 - list name

		variable-bound anonymous list reference:

					1 - #variableList
					2 - target obj name
					3 - var name

		anonymous list (either within a list or bound to a variable):

					converted to tuples in place"

	| obj rcvr block stage |
	cellMorphs
		do: [ :m | 
			obj := m complexObject.
			(obj isKindOf: Array)
				ifTrue: [ 
					stage := target isNil
						ifTrue: [ PhratchFrameMorph someInstance workPane ]
						ifFalse: [ target ownerOrYourselfThatIsA: PhratchStageMorph ].
					rcvr := obj second = 'Stage'
						ifTrue: [ stage ]
						ifFalse: [ stage coerceSpriteArg: obj second ].
					#block = obj first
						ifTrue: [ 
							block := stage stackFromTupleList: obj third receiver: rcvr.
							m complexObject: block ].
					#namedList = obj first
						ifTrue: [ m complexObject: (stage listNamed: obj third targetName: obj second) ].
					#variableList = obj first
						ifTrue: [ m complexObject: (stage listInVarNamed: obj third targetName: obj second) ].
					#stage = obj first
						ifTrue: [ m complexObject: stage ].
					#sprite = obj first
						ifTrue: [ m complexObject: (stage coerceSpriteArg: obj second) ] ].
			(obj isKindOf: self class)
				ifTrue: [ 
					obj convertTuplesToStacks.
					m complexObject: obj ] ].
	self updateContents
]

{ #category : #'*PhratchObjStream' }
PhratchListMorph >> fieldsVersion [

	^ 3

]

{ #category : #'*PhratchObjStream' }
PhratchListMorph >> initFieldsFrom: anObjStream version: classVersion [
	"Note: To simplify my representation in the project file, my submorphs are removed before saving and restored when I am read in from an object file."

	| strings complex |
	super initFieldsFrom: anObjStream version: classVersion.

	listName := anObjStream nextField.
	strings := anObjStream nextField.
	classVersion > 1 ifTrue: [target := anObjStream nextField].
	classVersion > 2 ifTrue: [complex := anObjStream nextField].

	self removeAllMorphs.
	self addTitleAndControls; addScrollPane.
	titleMorph contents: listName.
	self newContents: strings.
	complex ifNotNil: [
		self complexContents: complex ].
	self fixLayout.
	self updateContents.

]

{ #category : #'*PhratchObjStream' }
PhratchListMorph >> storeFieldsOn: anObjStream [
	"Note: To simplify my representation in the project file, my submorphs are removed before saving and restored when I am read in from an object file."

	| strings complex |

	"self purge.	"

	strings := cellMorphs asArray collect: [:m | m firstSubmorph contents asString].
	complex := cellMorphs asArray collect: [:m | m complexObject].

	self removeAllMorphs.
	numberMorphs := #().

	super storeFieldsOn: anObjStream.
	anObjStream putField: listName.
	anObjStream putField: strings.
	anObjStream putField: target.
	anObjStream putField: complex.

	self addTitleAndControls; addScrollPane.
	titleMorph contents: listName.
	self newContents: strings.
	self complexContents: complex.
	self fixLayout.


]
