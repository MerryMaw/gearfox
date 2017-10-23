

-- Implementation of the famous and interesting Mandelbrot fractal o.O
-- By The Maw

local function mandelbort_max(zi, limit)
	local z = zi
	
	for t = 1, limit do
		local ab = complex.abs(z)
		if (ab > 2.0) then return t,ab end
		z = complex.add(complex.mul(z, z),zi)
	end
	
	return limit, 0
end

function GenerateMandelBrot(size,iter,width,off_x,off_y)
	off_x = off_x or 0
	off_y = off_y or 0
	width = width or 512
	
	local Set = {}
	
	for x = 1,width do
		local x0 = off_x - size/2 + size*x/width
		
		Set[x] = {}
	
		for y = 1,width do
			local y0 = off_y - size/2 + size*y/width
			local z0 = complex.new(x0,y0)
			local n,z = mandelbort_max(z0,iter)
			
			Set[x][y] = {n = n, z = z}
		end
	end
	
	return Set
end
