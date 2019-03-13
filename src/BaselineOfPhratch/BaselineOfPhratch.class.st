Class {
	#name : #BaselineOfPhratch,
	#superclass : #BaselineOf,
	#category : #BaselineOfPhratch
}

{ #category : #'as yet unclassified' }
BaselineOfPhratch >> addInstVars [

	InputEventSensor instVarIndexFor: #keyPressed ifAbsent: [InputEventSensor addInstVarNamed: #keyPressed].
	(InputEventSensor hasClassVarNamed: #ButtonDecodeTable) ifFalse: [InputEventSensor addClassVarNamed: #ButtonDecodeTable].

]

{ #category : #'as yet unclassified' }
BaselineOfPhratch >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec preLoadDoIt: #addInstVars.
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

{ #category : #'as yet unclassified' }
BaselineOfPhratch >> deps: spec [
	<baseline>
	spec
		project: 'WebBrowser'
		with: [ spec
				repository: 'http://smalltalkhub.com/mc/TorstenBergmann/WebBrowser/main';
				className: 'ConfigurationOfWebBrowser';
				version: #stable ]
]
