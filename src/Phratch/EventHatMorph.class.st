"
I am a hat block for stacks triggered by Scratch events.

"
Class {
	#name : #EventHatMorph,
	#superclass : #HatBlockMorph,
	#classVars : [
		'ThreadSafeMode'
	],
	#category : #'Phratch-Blocks'
}

{ #category : #'as yet unclassified' }
EventHatMorph class >> threadSafeMode [
	^ThreadSafeMode ifNil: [false]
]

{ #category : #'as yet unclassified' }
EventHatMorph class >> threadSafeMode: bool [
	ThreadSafeMode := bool
]

{ #category : #other }
EventHatMorph >> asBlockTuple [
	"Answer a tuple (Array) describing this block and its event name."

	^ Array with: #byob with: '' with: self class name with: self eventName

]

{ #category : #other }
EventHatMorph >> eventName [
	"Answer the name of this script."

	^ scriptNameMorph eventName

]

{ #category : #other }
EventHatMorph >> eventName: aString [
	"Set my event name. Used for initialization."

	scriptNameMorph eventName: aString.
	self fixBlockLayout.
	(self ownerOrYourselfThatIsA: PhratchViewerMorph) ifNotNil:[
		(self ownerOrYourselfThatIsA: PhratchViewerMorph) updateContents].

]

{ #category : #initialization }
EventHatMorph >> forStartEvent [

	| parts s m |
	super initialize.
	self removeAllMorphs.

	parts := PhratchTranslator labelPartsFor: 'when $Sprite$ clicked'.

	s := StringMorph new contents: parts first; font: (PhratchFrameMorph getFont: #Label); color: Color white;
		yourself.
	self addMorphBack: s.

	m := ImageMorph new form: (PhratchFrameMorph skinAt: #goButton).
	self addMorphBack: m.

	s := s fullCopy contents: parts second.
	self addMorphBack: s.

	"create scriptNameMorph but don't add it"
	scriptNameMorph := EventTitleMorph new eventName: 'Phratch-StartClicked'.

	self fixBlockLayout.

]

{ #category : #initialization }
EventHatMorph >> forceLayout [
	"My UpdatingStringMorph calls this when its contents change"

	self fixBlockLayout.
	(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph) ifNotNil:[
		(self ownerOrYourselfThatIsA: PhratchBlockPaletteMorph) fixLayout].

]

{ #category : #other }
EventHatMorph >> helpScreenName [
	"Answer the name of the help screen for this hat block, or nil if no help is available."

	(self isKindOf: MouseClickEventHatMorph) ifTrue: [^ 'mouseclickHat'].
	(self isKindOf: KeyEventHatMorph) ifTrue: [^ 'keyHat'].
	self eventName = 'Phratch-StartClicked'
		ifTrue: [^ 'startHat']
		ifFalse: [^ 'broadcastHat'].

	^ nil

]

{ #category : #initialization }
EventHatMorph >> initialize [

	| parts label |
	super initialize.
	self removeAllMorphs.

	parts := PhratchTranslator labelPartsFor: 'when I receive $Event$'.

	parts first size > 0 ifTrue: [
		label := StringMorph contents: parts first font: (PhratchFrameMorph getFont: #Label).
		label color: Color white.
		self addMorphBack: label].

	scriptNameMorph := EventTitleMorph new.
	self addMorphBack: scriptNameMorph.

	parts second size > 0 ifTrue: [
		label := (StringMorph contents: parts second font: (PhratchFrameMorph getFont: #Label)) color: Color white.
		self addMorphBack: label].

]

{ #category : #'pats in' }
EventHatMorph >> isPartsBin [
	^ false
]

{ #category : #other }
EventHatMorph >> printHatNameOn: aStream [
	"Append a human-readable string for this hat block's name to the given stream."

	| evtName |
	evtName := self eventName.
	evtName = 'Phratch-StartClicked'
		ifTrue: [aStream nextPutAll: 'when green flag clicked']
		ifFalse: [aStream nextPutAll: 'when I receive "', evtName, '"'].
	aStream cr.


]

{ #category : #other }
EventHatMorph >> startForEvent: aPhratchEvent [
	"Starts a process for this event hat triggered by the given event. Answer the process that was started or nil if no new process was started."
	"Details: The current policy is to stop and re-start the script for all events except key-pressed. Key-pressed events are just ignored if the script for that event is already running."

	| stage |

	" +++++++++ change the rule to 'ignore' by Dan Garcia's request for the Berkeley CS10 course   -jens ++++++++++++++++++++"

	self class threadSafeMode ifFalse: [
	(aPhratchEvent name = 'Phratch-KeyPressedEvent') ifFalse: [
		phratchProc ifNotNil: [self stop]]].  "non-key events stop currently running process, if any"

	self hasRunningProcess ifTrue: [^ nil].  "don't re-trigger if running"

	scriptOwner ifNil: [^ nil].
	(stage := scriptOwner ownerOrYourselfThatIsA: PhratchStageMorph) ifNil: [^ nil].
	phratchProc := stage startProcessFor: self.
	self changed.
	^ phratchProc

]
