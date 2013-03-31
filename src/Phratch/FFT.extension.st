Extension { #name : #FFT }

{ #category : #'*Phratch-extensions' }
FFT >> plot: samples in: rect [
	"Throw-away code just to check out a couple of examples"
	| dx pen min max x |
	Display fillWhite: rect; border: (rect expandBy: 2) width: 2.
	min := 1.0e30.  max := -1.0e30.
	samples do:
		[:v |
		min := min min: v.
		max := max max: v].
	pen := PhratchPen new.  pen up.
	x := rect left.
	dx := rect width asFloat / samples size.
	samples do:
		[:v | | y |
		y := (max-v) / (max-min) * rect height asFloat.
		pen goto: x asInteger @ (rect top + y asInteger).
		pen down.
		x := x + dx].
	max printString displayOn: Display at: (x+2) @ (rect top-9).
	min printString displayOn: Display at: (x+2) @ (rect bottom - 9)
]
