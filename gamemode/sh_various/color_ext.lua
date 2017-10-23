
function MixColor(col1,col2,mixAmount)
	return Color(
		Lerp(mixAmount,col1.r,col2.r),
		Lerp(mixAmount,col1.g,col2.g),
		Lerp(mixAmount,col1.b,col2.b),
		Lerp(mixAmount,col1.a,col2.a))
end