Extension { #name : #VariableFrame }

{ #category : #'*PhratchObjStream' }
VariableFrame >> convertStacksToTuples [

	| obj isCyclic |
	vars keysDo: [:key |
		obj := vars at: key. 
		(obj isKindOf: ScriptablePhratchMorph)
			ifTrue: [ vars at: key put: obj asReferenceTuple ]
			ifFalse: [
			(obj respondsTo: #convertStacksToTuples) ifTrue: [		"this must be a list or another variable"
				obj convertStacksToTuples ].
			(obj respondsTo: #asBlockTuple) ifTrue: [ 				"this must be a block"

				isCyclic := obj allMorphs anySatisfy: [ :m |
					(m isKindOf: SetterBlockMorph) | (m isKindOf: VariableBlockMorph) and: [
						m receiver == self or: [(m receiver isKindOf: self class) and: [m receiver isReferencing: self]] ]].
				isCyclic
					ifTrue: [ obj receiver: nil]
					ifFalse: [ vars at: key put: obj asBlockTuple ]]]]


]

{ #category : #'*PhratchObjStream' }
VariableFrame >> convertTuplesToStacks [
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

	| obj stage rcvr block |
	stage := PhratchFrameMorph someInstance workPane.
	vars
		keysDo: [ :key | 
			obj := vars at: key.
			(obj isKindOf: Array)
				ifTrue: [ 
					rcvr := obj second = 'Stage'
						ifTrue: [ stage ]
						ifFalse: [ stage coerceSpriteArg: obj second ].
					#block = obj first
						ifTrue: [ 
							block := stage stackFromTupleList: obj third receiver: rcvr.
							vars at: key put: block ].
					#namedList = obj first
						ifTrue: [ vars at: key put: (stage listNamed: obj third targetName: obj second) ].
					#variableList = obj first
						ifTrue: [ vars at: key put: (stage listInVarNamed: obj third targetName: obj second) ].
					#stage = obj first
						ifTrue: [ vars at: key put: stage ].
					#sprite = obj first
						ifTrue: [ vars at: key put: (stage coerceSpriteArg: obj second) ] ].
			(obj isKindOf: PhratchListMorph)
				ifTrue: [ obj convertTuplesToStacks ] ]
]

{ #category : #'*PhratchObjStream' }
VariableFrame >> fieldsVersion [

	^ 1

]

{ #category : #'*PhratchObjStream' }
VariableFrame >> initFieldsFrom: anObjStream version: classVersion [
	"Set my instance variables from the given object stream."

	self initFieldsNamed: #(
		vars
	) from: anObjStream.

]
