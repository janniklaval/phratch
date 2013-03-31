"
I store Scratch shared variables (shariables). See Tammy's image for the final version of this.

"
Class {
	#name : #MsgServerTestTammy,
	#superclass : #ProtoObject,
	#classVars : [
		'GlobalServer',
		'MyDict'
	],
	#category : #'Phratch-Networking'
}

{ #category : #'as yet unclassified' }
MsgServerTestTammy >> convertToDictionary: aString [
	"Answer a dictionary from the String.
	 Error if String is not well-formatted (i.e. created by called 'asString' on a Dictionary)."

	| result startsWith table midEntry endEntry midPt key endPt value temp aBoolean type |

	aString = 'a Dictionary()' ifTrue: [^ Dictionary new].

	" 'a Dictionary(''k1''->(''v1'' false) ''k2''->(2 false) ''k3''->(3 true) )'"
	result := aString.

	"convert to Dictionary"
	startsWith := 'a Dictionary'.
	(result beginsWith: startsWith) ifTrue: [
		result := (result copyFrom: (startsWith size + 2) to: (result size - 2) ) asString].  
	result := result copyReplaceAll: '''''' with: '''' asTokens: false.

	" '''k1''->(''v1'' false) ''k2''->(2 false) ''k3''->(3 true)'	"

	table := Dictionary new.
	midEntry := '->('.
	endEntry := ') '''.
	[(midPt := result findString: midEntry) > 0] whileTrue: [
		key := result copyFrom: 2 to: midPt - 2.
		endPt := result findString: endEntry.
		endPt > 0 ifFalse: [endPt := result size].
		value := result copyFrom: midPt + midEntry size - 1 to: endPt.
		table at: key asString put: value.
		endPt = result size 
			ifTrue: [result := '']
			ifFalse: [result := (result copyFrom: endPt + 2 to: result size) asString]].

	" a Dictionary('k1'->'(''v1'' false)' 'k2'->'(2 false)' 'k3'->'(3 true)' )"

	temp := Dictionary new.
	table keysAndValuesDo: [:k :v | 
		|v1 k1|
		aBoolean := v endsWith: 'true)'.
		type := ('*string*' match: v) ifTrue: [#string] ifFalse: [#number].
		v1 := v copyFrom: 2 to: v size - aBoolean asString size - type asString size - 4.
		k1 := k copyReplaceAll: '''''' with: '''' asTokens: false.
		(v1 beginsWith: '''') 
			ifTrue: [v1 := v1 copyFrom: 2 to: v1 size - 1]
			ifFalse: [v1 := v1 asNumber].
		temp at: k1 put: {v1. type. aBoolean}]. 

	^ temp.   

	"a Dictionary('k1'->('v1' false) 'k2'->(2 false) 'k3'->(3 true) )"

]

{ #category : #'request handling' }
MsgServerTestTammy >> initialize [

	super initialize.
	self readFromFile.
]

{ #category : #'request handling' }
MsgServerTestTammy >> processMessage: aByteArray [
	"Simple HTML variable getter/setter.
		/create/<varName>/<string or number>/1
		/set/<varName>/<string or number>/1234
		/get/<varName>
		/exists/<varName>
		/allvars
		/reset
		/connect
		/updateVars/<dict>"

	| urlParts varName value |
	
	MyDict ifNil: [MyDict := Dictionary new].
	urlParts := aByteArray asString findTokens: '/'.

	((urlParts size = 1) and: [urlParts first = 'connect']) ifTrue: [
		GlobalServer ifNotNil: [GlobalServer stopServer].
		GlobalServer := MsgServerTestTammy new.
		GlobalServer forkServerProcess.
		^ 'ok'].

	((urlParts size = 2) and: [urlParts first = 'updateVars']) ifTrue: [
		^ self updateVars: urlParts second].

	((urlParts size = 1) and: [urlParts first = 'reset']) ifTrue: [
		self resetDict.
		^ 'ok'].

	((urlParts size = 2) and: [urlParts first = 'exists']) ifTrue: [
		varName := urlParts second.
		(MyDict includesKey: varName) ifTrue: [^ 'true'] ifFalse: [^ 'false']].

	((urlParts size = 4) and: [urlParts first = 'create']) ifTrue: [
		"If variable already exists, return the value of the variable"
		varName := urlParts second.
		(MyDict includesKey: varName) ifTrue: [^ (MyDict at: varName) first asString].
		"Otherwise, put the default value sent"
		value := urlParts last.
		(urlParts third = #number) ifTrue: [value := value asNumber].
		MyDict at: varName put: {value. false}.
		self saveToFile.
		^ 'ok'].

	((urlParts size = 4) and: [urlParts first = 'set']) ifTrue: [
		varName := urlParts second.
		value := urlParts last.
		(urlParts third = #number) ifTrue: [value := value asNumber].
		MyDict at: varName put: {value. false}.
		self saveToFile.
		^ 'ok'].

	((urlParts size = 2) and: [urlParts first = 'get']) ifTrue: [
		^ (MyDict at: (urlParts second) ifAbsent: ['']) asString].

	((urlParts size = 1) and: [urlParts first = 'allvars']) ifTrue: [
		^ MyDict asString].

	^ 'error'




]

{ #category : #'request handling' }
MsgServerTestTammy >> readFromFile [

	| fName f buf saveLocation |
	saveLocation := 'netblox-vars.txt'.
	(FileSystem workingDirectory / saveLocation) exists ifFalse: [^ nil].
	fName := (FileSystem workingDirectory / saveLocation) fullName.
	f := (FileStream readOnlyFileNamed: fName) binary.
	buf := f contentsOfEntireFile.
	MyDict := ObjStream new readObjFrom: (ReadStream on: buf)

]

{ #category : #'request handling' }
MsgServerTestTammy >> resetDict [
	
	MyDict := Dictionary new.
	self saveToFile.
]

{ #category : #'request handling' }
MsgServerTestTammy >> saveToFile [

	| f |
	f := (FileStream fileNamed: (FileSystem workingDirectory / 'netblox-vars.txt') fullName) binary.
	ObjStream new storeObj: MyDict on: f.
	f close
]

{ #category : #'request handling' }
MsgServerTestTammy >> updateVars: dictionaryString [

	| clientDict value temp |

	"Returns a dictionary of this form:
		a Dictionary('var1'->('val1' #string false) 'var2'->(2 #number false) 'var3'->('val3' #string true) )
	where the boolean represents whether it needs to be updated on the server"
	clientDict := self convertToDictionary: dictionaryString.

	"update values on the server"
	clientDict keysAndValuesDo: [:k :v |
		(v third) | ((MyDict includesKey: k) not) ifTrue: [MyDict at: k put: {v first. v second. false}]].

	"update values to be sent back to the client"
	temp := (clientDict keysDo: [:k | 
		value := MyDict at: k.
		clientDict at: k put: {value first. value second. false}]) asString.

	^ temp
]
