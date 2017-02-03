Extension { #name : #DialogBoxMorph }

{ #category : #'*PhratchSensing' }
DialogBoxMorph class >> inform: informationString title: titleString [
	"Put up an instance of me to give the user an informational message and wait until they click the 'ok' button before proceeding."

	"DialogBoxMorph inform: 'Operation complete.' title: 'Status'"

	| dialogBox |
	dialogBox := self new
		withButtonsForYes: false
			no: false
			okay: true
			cancel: false;
		title: ' ',titleString, ' ';
		yourself.
	dialogBox message: informationString font: (PhratchFrameMorph getFont: #DialogBoxMessage).
	^ dialogBox getUserResponse
]
