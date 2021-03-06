Class {
	#name : #BaselineOfPhratch,
	#superclass : #BaselineOf,
	#category : #BaselineOfPhratch
}

{ #category : #baseline }
BaselineOfPhratch >> addInstVars [

	InputEventSensor instVarIndexFor: #keyPressed ifAbsent: [InputEventSensor addInstVarNamed: #keyPressed].
	(InputEventSensor hasClassVarNamed: #ButtonDecodeTable) ifFalse: [InputEventSensor addClassVarNamed: #ButtonDecodeTable].

]

{ #category : #baseline }
BaselineOfPhratch >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec preLoadDoIt: #addInstVars.
			spec postLoadDoIt: #postLoad.
			self deps: spec.
			spec package: 'Phratch' with: [ spec requires: #('WebBrowser') ].
			spec package: 'PhratchColor' with: [ spec requires: #('Phratch') ].
			spec package: 'PhratchFile' with: [ spec requires: #('Phratch') ].
			spec package: 'PhratchList' with: [ spec requires: #('Phratch') ].
			spec package: 'PhratchLooks' with: [ spec requires: #('Phratch') ].
			spec package: 'PhratchMotion' with: [ spec requires: #('Phratch') ].
			spec package: 'PhratchPen' with: [ spec requires: #('Phratch') ].
			spec
				package: 'PhratchSensing'
				with: [ spec requires: #('Phratch') ].
			spec
				package: 'PhratchDebugger'
				with: [ spec requires: #('Phratch') ] ]
]

{ #category : #baseline }
BaselineOfPhratch >> deps: spec [
	<baseline>
	spec
		project: 'WebBrowser'
		with: [ spec
				repository: 'http://smalltalkhub.com/mc/TorstenBergmann/WebBrowser/main';
				className: 'ConfigurationOfWebBrowser';
				version: #stable ]
]

{ #category : #baseline }
BaselineOfPhratch >> postLoad [
	Smalltalk at: #MenubarMorph ifPresent: [ :morph | morph reset ]
]
