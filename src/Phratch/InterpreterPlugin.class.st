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

	"add #include for my header file, if any"
	self headerFile ifNotNil: [
		aCCodeGenerator addHeaderFile: '"', self moduleName,'.h"'].

]

{ #category : #translation }
InterpreterPlugin class >> headerFile [
	"If there is a header file to be associated with the plugin, here is where you put it. It will be generated and included automatically."

	^ nil

]

{ #category : #accessing }
InterpreterPlugin class >> moduleName [
	"Answer the receiver's module name that is used for the plugin's C code."

	^ self name asString

]
