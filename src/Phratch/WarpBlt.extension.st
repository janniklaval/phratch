Extension { #name : #WarpBlt }

{ #category : #'*Phratch-Extensions' }
WarpBlt class >> rotatePhratch: srcForm degrees: angleInDegrees center: rotationPoint scaleBy: scalePoint smoothing: cellSize [
	"Rotate the given Form the given number of degrees about the given center and scale its width and height by x and y of the given scale point. Smooth using the given cell size, an integer between 1 and 3, where 1 means no smoothing. Return a pair where the first element is the rotated Form and the second is the position offset required to align the rotationPoint of the rotated Form with that of the original. Note that the dimensions of the resulting Form generally differ from those of the original."

	| srcRect center radians dstOrigin dstCorner p dstRect dstExtent inverseScale quad warpSrc dstForm  oldOffset newRotationPoint |
	srcRect := srcForm boundingBox.
	center := srcRect extent / 2.0.
	radians := angleInDegrees degreesToRadians.
	dstOrigin := dstCorner := center.
	srcRect corners do: [:corner |
		"find the limits of a rectangle that just encloses the rotated
		 original; in general, this rectangle will be larger than the
		 original (e.g., consider a square rotated by 45 degrees)"
		p := ((corner - center) scaleBy: scalePoint) + center.
		p := p rotateBy: radians about: center.
		dstOrigin := dstOrigin min: p.
		dstCorner := dstCorner max: p].

	"rotate the enclosing rectangle back to get the source quadrilateral"
	dstRect := dstOrigin corner: dstCorner.
	dstExtent := dstRect extent rounded.
	inverseScale := (1.0 / scalePoint x)@(1.0 / scalePoint y).
	quad := dstRect innerCorners collect: [:corner |
		p := corner rotateBy: radians negated about: center.
		((p - center) scaleBy: inverseScale) + center].

	"make a Form to hold the result and do the rotation"
	warpSrc := srcForm.
	(srcForm isKindOf: ColorForm) ifTrue: [
		warpSrc := Form extent: srcForm extent depth: 16.
		srcForm displayOn: warpSrc].
	dstForm := Form extent: dstExtent depth: (warpSrc depth max: 16).

	(WarpBlt toForm: dstForm)
		sourceForm: warpSrc;
		colorMap: (dstForm colormapIfNeededForDepth: warpSrc depth);
		cellSize: cellSize;  "installs a new colormap if cellSize > 1"
		combinationRule: Form paint;
		copyQuad: quad toRect: dstForm boundingBox.

	oldOffset := (rotationPoint - center truncated) * scalePoint.
	newRotationPoint := (dstForm extent / 2.0) + (oldOffset rotateBy: radians about: 0@0).
	^ Array with: dstForm with: newRotationPoint - rotationPoint

]
