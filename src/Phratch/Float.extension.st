Extension { #name : #Float }

{ #category : #'*Phratch-Extensions' }
Float >> absFixedPrintBase10On: aStream [
	"Like absPrintExactlyOn:base: but (a) always base 10 and (b) never uses expontential notation."

	| base fBase significand exp baseExpEstimate be be1 r s mPlus mMinus scale roundingIncludesLimits d tc1 tc2 decPointCount |
	self isInfinite ifTrue: [aStream nextPutAll: 'Infinity'. ^ self].
	base := 10.
	fBase := base asFloat.
	significand := self significandAsInteger.
	roundingIncludesLimits := significand even.
	exp := (self exponent - 52) max: MinValLogBase2.
	baseExpEstimate := (self exponent * fBase reciprocalLogBase2 - 1.0e-10) ceiling.
	exp >= 0
		ifTrue:
			[be := 1 << exp.
			significand ~= 16r10000000000000
				ifTrue:
					[r := significand * be * 2.
					s := 2.
					mPlus := be.
					mMinus := be]
				ifFalse:
					[be1 := be * 2.
					r := significand * be1 * 2.
					s := 4.
					mPlus := be1.
					mMinus := be]]
		ifFalse:
			[(exp = MinValLogBase2) | (significand ~= 16r10000000000000)
				ifTrue:
					[r := significand * 2.
					s := (1 << (exp negated)) * 2.
					mPlus := 1.
					mMinus := 1]
				ifFalse:
					[r := significand * 4.
					s := (1 << (exp negated + 1)) * 2.
					mPlus := 2.
					mMinus := 1]].
	baseExpEstimate >= 0
		ifTrue: [s := s * (base raisedToInteger: baseExpEstimate)]
		ifFalse:
			[scale := base raisedToInteger: baseExpEstimate negated.
			r := r * scale.
			mPlus := mPlus * scale.
			mMinus := mMinus * scale].
	(r + mPlus > s) | (roundingIncludesLimits & (r + mPlus = s))
		ifTrue: [baseExpEstimate := baseExpEstimate + 1]
		ifFalse:
			[r := r * base.
			mPlus := mPlus * base.
			mMinus := mMinus * base].

	decPointCount := baseExpEstimate.
	baseExpEstimate <= 0 ifTrue: [
		aStream nextPutAll: '0.'.
		baseExpEstimate negated timesRepeat: [aStream nextPut: $0]].

	[d := r // s.
	r := r \\ s.
	(tc1 := (r < mMinus) | (roundingIncludesLimits & (r = mMinus))) |
	(tc2 := (r + mPlus > s) | (roundingIncludesLimits & (r + mPlus = s)))] whileFalse:
		[aStream nextPut: (Character digitValue: d).
		r := r * base.
		mPlus := mPlus * base.
		mMinus := mMinus * base.
		decPointCount := decPointCount - 1.
		decPointCount = 0 ifTrue: [aStream nextPut: $.]].
	tc2 ifTrue:
		[tc1 not | (tc1 & (r*2 >= s)) ifTrue: [d := d + 1]].
	aStream nextPut: (Character digitValue: d).
	decPointCount > 0
		ifTrue:
		[decPointCount - 1 to: 1 by: -1 do: [:i | aStream nextPut: $0].
		aStream nextPutAll: '.0'].
]

{ #category : #'*Phratch-Extensions' }
Float >> printStringNoExponent [
	"Answer a printed representation of me that does not use exponential notation."

	| s |
	self isNaN ifTrue: [^ 'NaN']. "check for NaN before sign"
	self = 0.0 ifTrue: [^ '0.0'].
	s := WriteStream on: (String new: 100).
	self > 0.0
		ifTrue: [self absFixedPrintBase10On: s]
		ifFalse: [
			s nextPutAll: '-'.
			self negated absFixedPrintBase10On: s].

	^ s contents
]
