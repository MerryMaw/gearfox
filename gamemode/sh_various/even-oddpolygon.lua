

function IsPointInPath(p,dat)
	local num = #dat
	local i = 1
	local j = num
	local c = false
	
	for i = 1,num do
		if ((dat[i].y > p.y) != (dat[j].y > p.y)) and
			(p.x < (dat[j].x - dat[i].x) * (p.y - dat[i].y) / (dat[j].y - dat[i].y) + dat[i].x) then
			c = !c
		end
		j = i
	end
	
	return c
end
		