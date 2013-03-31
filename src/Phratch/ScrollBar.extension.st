Extension { #name : #ScrollBar }

{ #category : #'*Phratch-Extensions' }
ScrollBar >> percentVisible: d [
	"Supply an optional floating fraction so slider can expand to indicate the percent of the content that is visible."

	interval := d min: 1.0.
	self expandSlider.
	self computeSlider.
]
