Extension { #name : #String }

{ #category : #'*PhratchSound' }
String >> localizedMIDI [
	"Answer myself translated into the current Scratch language. If there is no translation for me, then answer myself."

	PhratchTranslator addMIDITranslation: self.
	^ PhratchTranslator translationFor: self
]
