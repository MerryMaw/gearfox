
--[[---------------------------------------------------------
	Taken from Lua.org, in regards of complex numbers
-----------------------------------------------------------]]

complex = complex or {}
    
function complex.new(r, i) return {r=r, i=i} end

complex.i = complex.new(0, 1)

function complex.add(c1, c2)
  return complex.new(c1.r + c2.r, c1.i + c2.i)
end

function complex.sub(c1, c2)
  return complex.new(c1.r - c2.r, c1.i - c2.i)
end

function complex.mul(c1, c2)
	return complex.new(c1.r*c2.r - c1.i*c2.i,
					   c1.r*c2.i + c1.i*c2.r)
end

function complex.abs(c1) --Should use some sort of hypot instead.
	return math.sqrt(c1.r^2 + c1.i^2)
end

function complex.inv(c)
	local n = c.r^2 + c.i^2
	return complex.new(c.r/n, -c.i/n)
end