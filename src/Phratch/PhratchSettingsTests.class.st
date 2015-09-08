Class {
	#name : #PhratchSettingsTests,
	#superclass : #TestCase,
	#category : #'Phratch-Tests'
}

{ #category : #'as yet unclassified' }
PhratchSettingsTests >> settingsExportTest [
	| settingsBrowser nodes |
	settingsBrowser := SettingBrowser new.
	nodes := settingsBrowser treeHolder nodeList.	"settingsBrowser  exportSettings"
 	nodes do: [:e  | e item exportSettingAction ] .
		

]

{ #category : #'as yet unclassified' }
PhratchSettingsTests >> testPhratchPragmas [
	| pragmas   wrongPragmas |
	"phratchSettingsOn: aBuilder  "	
 
	wrongPragmas := OrderedCollection new.
	ScriptablePhratchMorph allSubclasses
						do: [ :aSC |
	pragmas := (Pragma allNamed: #phratchItem:kind:category:defaultValues:subCategory:special: in: aSC)
		asOrderedCollection.
 
	pragmas
		do: [ :pragma | 
			(pragma arguments at: 1 ) class ~= ByteString
				ifTrue: [ wrongPragmas add: pragma] ]].
	self assert: wrongPragmas isEmpty 
]

{ #category : #'as yet unclassified' }
PhratchSettingsTests >> testSettingsExport [
	self settingsExportTest.
	self assert: true.
]
