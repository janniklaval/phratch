Class {
	#name : #InterpreterPlugin,
	#superclass : #Object,
	#instVars : [
		'interpreterProxy',
		'moduleName'
	],
	#category : #'Phratch-Primitives-Plugins'
}

{ #category : #private }
InterpreterPlugin class >> codeGeneratorClass [
	"Answer the appropriate code generator class."

	^ PluggableCodeGenerator

]

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

{ #category : #initialize }
InterpreterPlugin >> setInterpreter: anInterpreter [ 
	"Note: This is coded so that is can be run from Squeak."

	| ok |
	self export: true.
	self var: #anInterpreter type: #'struct VirtualMachine*'.
	interpreterProxy := anInterpreter.
	ok := self cCode: 'interpreterProxy->majorVersion() == VM:=PROXY:=MAJOR'.
	ok == false ifTrue: [^ false].
	ok := self cCode: 'interpreterProxy->minorVersion() >= VM:=PROXY:=MINOR'.
	^ ok

]
