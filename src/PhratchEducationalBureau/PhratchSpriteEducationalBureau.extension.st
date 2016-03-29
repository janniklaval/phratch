Extension { #name : #PhratchSpriteEducationalBureau }

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteEducationalBureau >> closePort [
	<phratchItem: 'close port' kind: #- category: 'educational bureau' defaultValues: #() subCategory: #a special: #()>
 
	[self say: 'I am closing the connection'.
	[serialPort close] on: Error do: [PhratchError error: 'serial port cannot be closed'].
	myPortName := nil.
	Smalltalk garbageCollect.
	2 seconds wait.
	self sayNothing.
	] fork
]

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteEducationalBureau >> initialize [

	super initialize.
	self setMyName: 'Educ-Bureau'.
	self initializeSkin.
	self gotoX: 0 y: 0.
]

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteEducationalBureau >> initializeSkin [
	| botSkin botImage |
	botSkin := Form fromFileNamed: (FileSystem workingDirectory / 'ScratchSkin' / 'defaultSpriteCostume.png').

	botImage := ImageMedia new form: botSkin.
	botImage mediaName: (self unusedMediaNameFromBaseName: (self defaultImageMedia mediaName)).
	media addLast: botImage.
	self lookLike: botImage mediaName.
	self updateMediaCategory.
	
]

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteEducationalBureau >> lastValue [
	<phratchItem: 'last read value' kind: #ReporterBlockMorph category: 'educational bureau' defaultValues: #() subCategory: #c special: #()>
	
	^ lastString
]

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteEducationalBureau >> lastValueAt: anIndex [
	<phratchItem: 'last read value at $Number$' kind: #ReporterBlockMorph category: 'educational bureau' defaultValues: #() subCategory: #c special: #()>
	
	^ lastString at: anIndex asInteger
]

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteEducationalBureau >> openPort: aPortName [
	<phratchItem: 'open port $String$' kind: #- category: 'educational bureau' defaultValues: #('COM4') subCategory: #a special: #()>
	[self say: 'I am waiting for connection'.
	myPortName := aPortName.
   serialPort := [SerialPort new openPort: aPortName] on: Error do: [nil].
	serialPort isNil 
		ifTrue:[self say: 'I am not connected'.]
		ifFalse:[self say: 'I am connected'.].
	2 seconds wait.
	self sayNothing.
	
	] fork
]

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteEducationalBureau >> readAll [
	<phratchItem: 'read all' kind: #ReporterBlockMorph category: 'educational bureau' defaultValues: #('COM4') subCategory: #b special: #()>
	|str strDecript stopWait|	

	stopWait := false.
	"["self say: 'I am waiting for data'.
	
	str := serialPort readString. 
	[str isEmpty and: [stopWait = false]] whileTrue:[str := serialPort readString.]. 

	strDecript := (str subStrings: ',') collect: [ :i | PhratchEducationalBureau characterAt: (i asInteger) ].
	
	"15 seconds wait.
	stopWait := true.
	self sayNothing.
	] fork."
	self sayNothing.
	"strDecript isNil 
		ifTrue:[self say: 'No data'.]
		ifFalse:[self say: '', strDecript.]."
		lastString:= '',strDecript.
	^ lastString.
]

{ #category : #'*PhratchEducationalBureau' }
PhratchSpriteEducationalBureau >> readAt: anIndex [
	<phratchItem: 'read at $Number$' kind: #ReporterBlockMorph category: 'educational bureau' defaultValues: #('1') subCategory: #b special: #()>
	
	^(self readAll at: (anIndex))
]
