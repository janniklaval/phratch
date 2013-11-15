"
A TextStopConditions is a private helper class for text composition (See class CharacterScanner and subclasses).
It maps some characters controling the text layout (like carriage return, line feeds, space and tabulation) to some selector representing the action to be performed by the CharacterScanner.
By default, a TextStopConditions does not map any action to control character; instances must be properly initialized by sending #at:put: messages.

For example, inter-word spacing can be adjusted so as to obtain ""justified"" paragraphs. See implementors of #paddedSpace, #cr, #space, #columnBreak for example of special character actions.

A TextStopConditions also store two selectors for mapping the actions to be taken when:
- end of run is encountered;
- text overflows horizontal composition bounds.
These actions are by default #endOfRun and #crossedX (see implementors of these messages), but can enventually be changed using #endOfRun: and #crossedX:.

In a text (see class Text), the ""runs"" are used to store text style attributes, so an ""end of run"" event probably means some action in the textcomposer should be taken to change the font.

TextStopConditions current implementation can only map 256 character codes (from 1 to 256). It is the composer responsibility to encode the character before sending #at:. Presumably, the composer will use the character codePoint + 1 (see implementors of #codePoint).
If this is not sufficient, then this class could be changed to use a Dictionary or a LargeTable

Historically, the EndOfRun and CrossedX were two TextConstant of value 257 and 258, which did occupy corresponding slots in the stops array. Since these are valid character codePoint, this usage has been deprecated. However, because any error in text composition would have catastrophic consequences (unresponsive user interface), backward compatibility with obsolete historical code is still maintained internally which is why the stops array has a sze of 258.

Instance Variables
	crossedX:		<Symbol | nil>
	endOfRun:		<Symbol | nil>
	stops:		<Array of: Symbol | nil>

crossedX
	- selector to perform when the composed text overflows X composition bound

endOfRun
	- selector to perform at end of run

stops
	- an array mapping character code (codePoint + 1) to special actions, or nil if character is to be rendered normally

"
Class {
	#name : #TextStopConditions,
	#superclass : #Object,
	#instVars : [
		'stops',
		'crossedX',
		'endOfRun'
	],
	#category : #PhratchCompatibilityPharo3
}

{ #category : #accessing }
TextStopConditions >> at: anInteger [
	"Answer the special action associated with a character of code anInteger, or nil if none.
	The character code should be betxween 1 and 256 (presumably codePoint + 1).
	It can eventually be 257 for endOfRun action, or 258 for crossedX action for backward compatibility with historical squeak versions."
	
	^stops at: anInteger
]

{ #category : #accessing }
TextStopConditions >> at: anInteger put: aSymbolOrNil [
	"Set the special action associated with a character of code anInteger, or nil if none.
	The character code should be betxween 1 and 256 (presumably codePoint + 1).
	It can eventually be 257 for endOfRun action, or 258 for crossedX action for backward compatibility with historical squeak versions."
	
	anInteger = 257
		ifTrue: [
			self endOfRun: aSymbolOrNil..
			^aSymbolOrNil].
	anInteger = 258
		ifTrue: [
			self crossedX: aSymbolOrNil..
			^aSymbolOrNil].
	^stops at: anInteger put: aSymbolOrNil
]

{ #category : #accessing }
TextStopConditions >> crossedX [
	"Answer the special action to be performed when crossing composition bounds."
	
	^crossedX
]

{ #category : #accessing }
TextStopConditions >> crossedX: aSymbolOrNil [
	crossedX := aSymbolOrNil.
	
	"Backward compatibility with historical EndOfRun TextConstant handling"
	stops size >= 258 ifTrue: [stops at: 258 put: crossedX]
]

{ #category : #accessing }
TextStopConditions >> endOfRun [
	"Answer the special action to be performed et end of text."
	
	^endOfRun
]

{ #category : #accessing }
TextStopConditions >> endOfRun: aSymbolOrNil [
	endOfRun := aSymbolOrNil.
	
	"Backward compatibility with historical EndOfRun TextConstant handling"
	stops size >= 257 ifTrue: [stops at: 257 put: endOfRun]
]

{ #category : #'initialize-release' }
TextStopConditions >> initialize [
	"Initialize the default stop conditions."
	stops := Array new: 258.
	self endOfRun: #endOfRun.
	self crossedX: #crossedX.
]

{ #category : #copying }
TextStopConditions >> postCopy [
	stops := stops copy
]

{ #category : #'initialize-release' }
TextStopConditions >> setStops: stopArray [
	stops := stopArray
]

{ #category : #accessing }
TextStopConditions >> size [
	"Return the highest code to which an action can be mapped.
	Do not take into account the two slots for endOfRun and crossedX, since they don't map any character code.
	Warning: this message is used for compatibility with obsolete code."
	
	^256
]
