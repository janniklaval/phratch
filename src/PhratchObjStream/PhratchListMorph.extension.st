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
