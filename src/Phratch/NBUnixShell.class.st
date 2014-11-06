Class {
	#name : #NBUnixShell,
	#superclass : #Object,
	#category : #Phratch
}

{ #category : #'as yet unclassified' }
NBUnixShell class >> open: aString [
	"self open: 'http://www.google.com'"

	| openCommand |
	openCommand := 'xdg-open "{1}"' format: { aString }.
	self run: openCommand.
]

{ #category : #'as yet unclassified' }
NBUnixShell class >> run: commandString [
	"self run: 'open http://www.google.com'."

	<primitive: #primitiveNativeCall module: #NativeBoostPlugin error: errorCode >
	^ self nbCall: #( int system (String commandString) ) module: NativeBoost CLibrary 
]
