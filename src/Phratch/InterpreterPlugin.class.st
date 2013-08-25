Class {
	#name : #InterpreterPlugin,
	#superclass : #Object,
	#instVars : [
		'interpreterProxy'
	],
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #translation }
InterpreterPlugin class >> declareCVarsIn: aCCodeGenerator [
	"Note: This method must be implemented by all subclasses to declare variables."

	aCCodeGenerator var: #interpreterProxy type: #'struct VirtualMachine*'.
]
