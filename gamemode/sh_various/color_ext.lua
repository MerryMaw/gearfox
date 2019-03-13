
function MixColor(col1,col2,mixAmount)
	return Color(
		Lerp(mixAmount,col1.r,col2.r),
		Lerp(mixAmount,col1.g,col2.g),
		Lerp(mixAmount,col1.b,col2.b),
		Lerp(mixAmount,col1.a,col2.a))
end

function ColorToHex(col)
	return string.format("#%02x%02x%02x", col.r,col.g,col.b)
end

function HexToColor(hex)
    hex = hex:gsub("#","")
    return Color(tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6)))
end