Extension { #name : #ScriptablePhratchMorph }

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> attribute: attr [

	self subclassResponsibility 
]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> attribute: attr of: anObject [
	"Answer the variable or built-in attribute value for the given sprite. Answer zero if the given sprite does not have a built-in attribute or variable of the given name."
	<phratchItem: 'get $Attributes$ of $Sprite$' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #() subCategory: #a3 special: #()>
	| aSpriteOrStage |
	aSpriteOrStage := self coerceSpriteArg: anObject.

	(aSpriteOrStage isScriptablePhratchMorph) ifFalse: [^ 0].
	^ aSpriteOrStage attribute: attr

]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> doAsk [
	"Ask for the given question, and wait for an answer"
	<phratchItem: 'ask $String$ and wait' kind: #SpecialBlockMorph category: 'sensing' defaultValues: #('What''s your name?') subCategory: #a1 special: #()>
	
]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> getAttribute: attr of: anObject [
	"Answer the variable or built-in attribute value for the given sprite. Answer zero if the given sprite does not have a built-in attribute or variable of the given name."
	<phratchItem: '$Attributes$ of $Sprite$' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #() subCategory: #a3 special: #()>
	| aSpriteOrStage |
	aSpriteOrStage := self coerceSpriteArg: anObject.
	(aSpriteOrStage isScriptablePhratchMorph) ifFalse: [^ 0].
"	^ aSpriteOrStage getAttribute: attr asString"
	^ aSpriteOrStage attribute: attr


]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> getObject: anObject [
	"Return the given sprite"
	<phratchItem: 'object $Sprite$' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #() subCategory: #a3 special: #()>
	^ anObject
]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> keyPressed [
	"Answer the currently pressed key."
	<phratchItem: 'key pressed' kind: #ReporterBlockMorph category: 'sensing' defaultValues: #() subCategory: #a2 special: #()>
	self flag: 'TODO: This needs to be rewritten to use Sensor keyboard or the like.'.
	self keyNames do: [:ch |
		(self keyPressed: ch) ifTrue: [^ ch]].
	^ ''.
]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> mousePressed [
	"Return true if the mouse is pressed"
	<phratchItem: 'mouse down?' kind: #BooleanBlockMorph category: 'sensing' defaultValues: #() subCategory: #a2 special: #()>
	^ Sensor redButtonPressed

]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> promptForInput: questionString [

	| s prompter |
	(s := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ self].
	prompter := PhratchPrompterMorph new.
	((self isPhratchStageMorph) | (self isHidden))
		ifTrue: [
			prompter question: questionString]
		ifFalse: [
			self showQuestion: questionString.
			prompter sprite: self].

	prompter left: s center x - (prompter width // 2).
	prompter bottom: s bottom - 5.
	prompter isSticky: true.

	s addMorphFront: prompter.
	prompter grabKeyboardFocus.
"	World doOneCycle."

	^ prompter

	
]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> promptInProgress [

	| s |
	(s := self ownerOrYourselfThatIsAPhratchStageMorph) ifNil: [^ false].
	s submorphsDo: [:m |
		(m isPhratchPrompterMorph) ifTrue: [^ true]].
	^ false

]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> showAskDialogWithText: text [ 
	"Show a popup with the given question. Wait for the answer."
	<phratchItem: 'ask $String$ in dialog' kind: #- category: 'sensing' defaultValues: #('What''s your name?') subCategory: #a1 special: #()>
	"Show an information dialog with the given title and text."
	PhratchPrompterMorph lastAnswer: (StringDialog ask: text).
	
	self updateAfterPopUp.
	
]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> showInformDialog: title withText: text [ 
	"Show a popup with the given information. Wait for the user to click on the OK button"
	<phratchItem: 'show dialog $String$ with text $String$' kind: #- category: 'sensing' defaultValues: #('info' '') subCategory: #a1 special: #()>
	"Show an information dialog with the given title and text."
	DialogBoxMorph inform: text title: title.
	
	self updateAfterPopUp.
]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> timer [
	"Return the timer"
	<phratchItem: 'timer' kind: #ReporterWatcherBlockMorph category: 'sensing' defaultValues: #() subCategory: #timer special: #()>
	| now |
	now := Time millisecondClockValue.
	TimerStartMSecs ifNil: [ TimerStartMSecs := now ].
	TimerStartMSecs := TimerStartMSecs min: now.
	^ (now - TimerStartMSecs) asFloat / 1000.0
]

{ #category : #'*PhratchSensing' }
ScriptablePhratchMorph >> timerReset [
	"Reset the timer"
	<phratchItem: 'reset timer' kind: #- category: 'sensing' defaultValues: #() subCategory: #timer special: #()>
	TimerStartMSecs := Time millisecondClockValue.

]
