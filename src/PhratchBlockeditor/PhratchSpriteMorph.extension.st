Extension { #name : #PhratchSpriteMorph }

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> AddBlock: myClassName methodName: mName blockName: bName [
"Add Block"
|myCategory myClassification|
    <phratchItem: 'Add Block (category: $String$ methodName: $String$ blockName: $String$)' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #(newCategory myMethod myBlock) 
        subCategory: #a 
        special: #()> 

myCategory := WriteStream on: String new.
myCategory 
	nextPutAll: mName;
	cr;
	nextPutAll: '<phratchItem: ''';
	nextPutAll: bName;
	nextPutAll: '''';
	cr;
	nextPutAll: 'kind: #- ';
	cr;
	nextPutAll: 'category: ''';
	nextPutAll: myClassName asLowercase;
	nextPutAll: '''';
	cr;
	nextPutAll: 'defaultValues: #()';
	cr;
	nextPutAll: 'subCategory: #a';
	cr;
	nextPutAll: 'special: #()>';
	cr;	
	nextPutAll: '^Transcript open';
	cr.	

myClassification  := WriteStream on: String new.
myClassification 
	nextPutAll: '*Phratch';
	nextPutAll: myClassName.
	
PhratchSpriteMorph compile: myCategory contents
classified: myClassification contents.
^self

]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> Quit [
"Save Pharo image and Quit"
    <phratchItem: 'Only Quit' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #() 
        subCategory: #a 
        special: #()> 
^Smalltalk snapshot: false andQuit: true


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> addSpriteVariable: name [
	"Add sprite variable"
    <phratchItem: 'Add Sprite instance variable: $String$' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #(var1) 
        subCategory: #a 
        special: #()> 
^ PhratchSpriteMorph addInstVarNamed: name


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> browseBlockEditorBlocks [
"Browse Blockeditor Methods"
    <phratchItem: 'Browse BlockEditor Blocks' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #() 
        subCategory: #a 
        special: #()> 
    ^Nautilus openOnClass: PhratchSpriteMorph onProtocol: '*PhratchBlockeditor'
]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> browseBlockEditorClass [
"Browse Blockeditor class"
    <phratchItem: 'Browse BlockEditor class' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #() 
        subCategory: #a 
        special: #()> 
    ^PhratchCategoryBlockeditor   browse
]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> compilerEvaluate: comm [
	"Evaluate an expression"
    <phratchItem: 'Evaluate: $String$' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #('Transcript open') 
        subCategory: #a 
        special: #()> 
^ Compiler evaluate: comm


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> createCategory: name label: label r: r g: g b: b position: p [
"Create category"
|myClassName myCategory myLabel myColor bColor myOrder bOrder|
	"Create a new block category"
    <phratchItem: 'Create Category: $String$ Label: $String$ color(r: $Number$ g: $Number$ b: $Number$) position: $Number$' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #(newCategory myCategory 0 1 0 20) 
        subCategory: #a 
        special: #()> 
myClassName := name.
bColor := (Color r: r g: g b: b) asString.
bOrder:= p asString.

myCategory := WriteStream on: String new.
myCategory 
	nextPutAll: 'PhratchCategory subclass: #PhratchCategory';
	nextPutAll: myClassName;
	nextPutAll: ' ';
	nextPutAll: ' instanceVariableNames: '''' 
    classVariableNames: '''' 
    poolDictionaries: '''' 
    category: ''Phratch';
	nextPutAll: myClassName;
	nextPutAll: '''.'.

Compiler evaluate: myCategory contents.

myLabel := WriteStream on: String new.
myLabel
   nextPutAll: 'PhratchCategory';
	nextPutAll: myClassName;
	nextPutAll: ' class compile: ''label ^ ''''';
	nextPutAll: label asLowercase;
	nextPutAll: ''''''''.
	
Compiler evaluate: myLabel contents.

myColor := WriteStream on: String new.
myColor
   nextPutAll: 'PhratchCategory';
	nextPutAll: myClassName;
	nextPutAll: ' class compile: ''color ^ ';
	nextPutAll: bColor;
	nextPutAll: ''''.

Compiler evaluate: myColor contents.

myOrder := WriteStream on: String new.
myOrder
   nextPutAll: 'PhratchCategory';
	nextPutAll: myClassName;
	nextPutAll: ' class compile: ''order ^ ';
	nextPutAll: bOrder;
	nextPutAll: ''''.

Compiler evaluate: myOrder contents.
^ self


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> openPlayground [
"Open Playground"
    <phratchItem: 'Open Playground' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #() 
        subCategory: #a 
        special: #()> 
^GTPlayground  openLabel: 'BlockEditor Playground'


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> openPlayground: cont [
"Open Playground"
    <phratchItem: 'Open Playground with: $String$' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #('Transcript open') 
        subCategory: #a 
        special: #()> 
^GTPlayground  openContents: cont label: 'BlockEditor Playground'


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> openTranscript [ 
"Open Transcript"
    <phratchItem: 'open Transcript' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #() 
        subCategory: #a 
        special: #()> 
    ^Transcript openLabel: 'BlockEditor Transcript'
]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> openWorkspace [
"Open Workspace"
    <phratchItem: 'Open Workspace' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #() 
        subCategory: #a 
        special: #()> 
^Workspace  openLabel: 'BlockEditor Workspace'


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> phratchCloseandOpen [
"Close and Reopen"
    <phratchItem: 'Close and reopen Phratch' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #() 
        subCategory: #a 
        special: #()> 
PhratchFrameMorph allInstancesDo: [ :i | i delete ].
^PhratchFrameMorph open



]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> removeBlock: mName [
	"Remove a block"
    <phratchItem: 'Remove Block (Method Name: $String$)' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #(myMethod) 
        subCategory: #a 
        special: #()> 
PhratchSpriteMorph removeSelector: mName.
^ self


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> removeCategory: name [
|myClassName myCategory|
	"Remove category"
    <phratchItem: 'Remove Category: $String$' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #(newCategory) 
        subCategory: #a 
        special: #()> 
myClassName := name.
myCategory := WriteStream on: String new.
myCategory 
	nextPutAll: 'PhratchCategory';
	nextPutAll: myClassName;
	nextPutAll: ' removeFromSystem.';
	nextPutAll: ' Smalltalk globals organization removeCategory: ''Phratch';
	nextPutAll: myClassName;
	nextPutAll: '''.'.
	
	Compiler evaluate: myCategory contents.
^ self


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> removeProtocol: name [
|myClassName myCategory|
	"Remove protocol"
    <phratchItem: 'Remove Protocol: $String$' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #(newCategory) 
        subCategory: #a 
        special: #()> 
myClassName := name.
myCategory := WriteStream on: String new.
myCategory 
	nextPutAll: '*Phratch';
	nextPutAll: myClassName.
PhratchSpriteMorph removeProtocol: myCategory contents.
^ self


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> removeSpriteVariable: name [
	"Remove Sprite Instance Variable"
    <phratchItem: 'Remove Sprite instance variable: $String$' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #(var1) 
        subCategory: #a 
        special: #()> 
^ PhratchSpriteMorph removeInstVarNamed: name


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> saveImage [
"Save Pharo image"
    <phratchItem: 'Save Image' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #() 
        subCategory: #a 
        special: #()> 
^Smalltalk snapshot: true andQuit: false


]

{ #category : #'*PhratchBlockeditor' }
PhratchSpriteMorph >> saveImageAndQuit [
"Save Pharo image and Quit"
    <phratchItem: 'Save Image and Quit' 
        kind: #- 
        category: 'blockeditor' 
        defaultValues: #() 
        subCategory: #a 
        special: #()> 
^Smalltalk snapshot: true andQuit: true


]
