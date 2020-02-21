--[[
    Voronoi Graph creation module of the luaFortune library.

    Documentation and License can be found here:
    https://bitbucket.org/Jmaa/luafortune
--]]

voronoi = {
    version = 2.3
}

--------------------------------------------------------------------------------
-- Binary Heap

local Heap = {}
      Heap.__index = Heap

function Heap.new ()
    -- Creates a new Heap.
    -- @return Heap The new Heap.

    return setmetatable({len = 0}, Heap)
end

function Heap:empty()
    -- Checks if the Heap is empty.
    -- @return boolean Whether the Heap is empty or not.

    return self.len == 0
end

function Heap:insert(point)
    -- Inserts a point the Heap.
    -- @param point Either a Point or an Event.

    self.len = self.len + 1
    local new_record = self[self.len]
    local index = self.len
    while index > 1 do
        local parent_index = math.floor(index / 2)
        local parent_rec = self[parent_index]
        if point.x < parent_rec.x then
            self[index] = parent_rec
        else
            break
        end
        index = parent_index
    end
    self[index] = point
end

function Heap:pop()
    -- Returns the top of the Heap, and removes it.
    -- @return Point|Event The top element.

    local result = self[1]

    local last = self[self.len]
    local last_x = last.x

    self[self.len] = self[1]
    self.len = self.len - 1

    local parent_index = 1
    while parent_index * 2 <= self.len do
        local index = parent_index * 2
        if index+1 <= self.len and self[index+1].x < self[index].x then
            index = index + 1
        end
        local child_rec = self[index]
        if last_x < child_rec.x then
            break
        end
        self[parent_index] = child_rec
        parent_index = index
    end
    self[parent_index] = last
    return result
end

--------------------------------------------------------------------------------
-- Objects

local function new_point (x, y)
    -- Creates a new Point.
    -- @param x The x coordinate of the Point.
    -- @param y The y coordinate of the Point.
    -- @return Point The new Point.

    return {x=x,y=y}
end
voronoi.new_point = new_point

local function new_event (x_pos, point, arc)
    -- Creates a new Event.
    -- @param x_pos The x coordinate of the Event.
    -- @param point The Point linked to the Event.
    -- @param arc The Arc linked to the Event.
    -- @return Arc The new Event.

    return {x=x_pos,pnt=point,a=arc,valid=true}
end

local function new_arc (point, prev, next)
    -- Creates a new Arc.
    -- @param point The Point linked to the Event.
    -- @param prev The previous Arc.
    -- @param next The next Arc.
    -- @return Arc the new Arc.

    return {p=point,prev=prev,next=next,e=nil,s1=nil,s2=nil}
end

local function new_edge (first_point)
    -- Creates a new Edge.
    -- @param first_point The first Point for this Edge.
    -- @return Edge The newly created edge.

    return {p1=first_point,p2=nil,done=false}
end

----------------------------------------------
-- Misc functions

local function dist_point_to_point (p1, p2)
    -- Finds the distance between two Points.
    -- @param p1 The first point.
    -- @param p2 The second point.
    -- @return number The distance between the Points.

    return math.sqrt(math.pow(p1.x-p2.x,2)+math.pow(p1.y-p2.y,2))
end

local function quadratic_formula (p1, p2, l)
    -- Solves the quadratic equation of two points.
    -- @param p1 First Point.
    -- @param p2 Second Point.
    -- @param l Line on the x axis.
    -- @return The result on the y axis.

    local z1 = 2*(p1.x-l)
    local z2 = 2*(p2.x-l)

    local a = 1/z1 - 1/z2;
    local b = -2*(p1.y/z1 - p2.y/z2);
    local c = (p1.y*p1.y + p1.x*p1.x - l*l)/z1 - (p2.y*p2.y + p2.x*p2.x - l*l)/z2;

    return (-b -math.sqrt(b*b - 4*a*c))/(2*a);
end

local function intersection (p1, p2, l)
    -- Finds the intersection between two Points and a line.
    -- @param p1 The first Point.
    -- @param p2 The second Point.
    -- @param l Line on the x axis.
    -- @return number X coordinate of the intersect point.
    -- @return number Y coordinate of the intersect point.

    local p_x, p_y, res_y = p1.x, p1.y

    if p1.x == p2.x then
        res_y = (p1.y+p2.y)/2
    elseif p2.x == l then
        res_y = p2.y
    elseif p1.x == l then
        res_y = p1.y
        p_x, p_y = p2.x, p2.y
    else
        res_y = quadratic_formula(p1,p2,l)
    end

    return (p_x^2 + (p_y-res_y)^2 - l*l)/(2*p_x-2*l), res_y;
end

local function circle (a, b, c)
    -- Processes the circle created by three points.
    -- @param a First Point.
    -- @param b Second Point.
    -- @param c Third Point.
    -- @return boolean Whether or not a circle is constructed.
    -- @return number Event position on x axis.
    -- @return Point Center Point of the circle.

    if (b.x-a.x)*(c.y-a.y)-(c.x-a.x)*(b.y-a.y) > 0 then
        return false
    end

    local A, B, C, D = b.x - a.x, b.y - a.y, c.x - a.x, c.y - a.y
    local G = 2*(A*(c.y-b.y) - B*(c.x-b.x))

    if G==0 then
        return false
    end

    local E = A*(a.x+b.x) + B*(a.y+b.y)
    local F = C*(a.x+c.x) + D*(a.y+c.y)

    local circle_point = new_point((D*E-B*F)/G, (A*F-C*E)/G)
    return true, circle_point.x+dist_point_to_point(a,circle_point), circle_point
end

---------------------------------------------

local function intersect (p1, arc, return_point)
    -- Checks if a Point intersect an Arc, and possibly returns the intersecting
    -- point.
    -- @param p1 The Point to check.
    -- @param arc The Arc to check.
    -- @param return_point Whether or not to return the intersecting Point.
    -- @return boolean Whether or not there is an intersection.
    -- @return Point The intersecting Point.

    if arc.p.x == p1.x then
        return false
    end

    local a, b
    local p1_x, p1_y = p1.x, p1.y

    if arc.prev then
        _, a = intersection(arc.prev.p, arc.p, p1_x)
    end
    if arc.next then
        _, b = intersection(arc.p, arc.next.p, p1_x)
    end

    if (not arc.prev or a <= p1_y) and (not arc.next or p1_y <= b) then
        return true, return_point and new_point((arc.p.x^2+(arc.p.y-p1_y)^2-p1_x^2)/(2*arc.p.x-2*p1_x), p1_y)
    end
    return false
end


local function check_circle_event (arc, min_x, points_and_events)
    -- Checks for a circle event.
    -- @param arc The Arc to check.
    -- @param min_x The x coordinate to check.
    -- @param points_and_events The Heap to check through.

    if arc.e and arc.e.x ~= min_x then
        arc.e.valid = false
    end
    arc.e = nil

    if not arc.prev or not arc.next then
        return
    end

    local is_circle, event_x, circle_point = circle(arc.prev.p, arc.p, arc.next.p)
    if is_circle and event_x > min_x then
        arc.e = new_event(event_x,circle_point,arc)
        points_and_events:insert(arc.e)
    end
end

local function front_insert (point, arc, output, points_and_events)
    -- Performs the front insertion.
    -- @param point Point to do work with.
    -- @param arc The root Arc.
    -- @param output The list to output edges to.
    -- @param points_and_events The Heap to operate on.

    while arc do
        local does_intercept, intersect_point = intersect(point, arc, true)
        if does_intercept then
            local does_intercept_1 = arc.next and intersect(point,arc.next, false)
            if arc.next and not does_intercept_1 then
                local arc_new = new_arc(arc.p,arc,arc.next)
                arc.next.prev = arc_new
                arc.next = arc_new
            else
                arc.next = new_arc(arc.p,arc)
            end
            arc.next.s2 = arc.s2

            arc.next.prev = new_arc(point,arc,arc.next)
            arc.next = arc.next.prev

            arc = arc.next

            arc.s1 = new_edge(intersect_point)
            arc.prev.s2 = arc.s1
            table.insert(output,arc.s1)

            arc.s2 = new_edge(intersect_point)
            arc.next.s1 = arc.s2
            table.insert(output,arc.s2)

            check_circle_event(arc,      point.x, points_and_events)
            check_circle_event(arc.prev, point.x, points_and_events)
            check_circle_event(arc.next, point.x, points_and_events)
            return
        else
            arc = arc.next
        end
    end
end

local function process_event (event, output, points_and_events)
    -- Process an event.
    -- @param event Event to process.
    -- @param output The list to output edges to.
    -- @param points_and_events The Heap to operate on.

    local arc = event.a

    local s1 = arc.s1
    local s2 = arc.s2
    if s1 and not s1.done then
        s1.p2, s1.done = event.pnt, true
    end
    if s2 and not s2.done then
        s2.p2, s2.done = event.pnt, true
    end

    local segment = new_edge(event.pnt)
    table.insert(output,segment)

    if arc.next then
        arc.next.prev = arc.prev
        arc.next.s1 = segment
    end
    if arc.prev then
        arc.prev.next = arc.next
        arc.prev.s2 = segment
        check_circle_event(arc.prev,event.x,points_and_events)
    end
    if arc.next then
        check_circle_event(arc.next,event.x,points_and_events)
    end
end


local function finish_edges (arc, p1_x, p1_y, p2_x, p2_y)
    -- Finishes the edges of the graph.
    -- @param arc The root arc.
    -- @param p1_x Minimum x.
    -- @param p1_y Minimum y.
    -- @param p2_x Maximum x.
    -- @param p2_y Maximum y.

    local l = p2_x + (p2_x-p1_x)+(p2_y-p1_y)
    while arc do
        local s2 = arc.s2
        if s2 and not s2.done then
            s2.done, s2.p2 = true, new_point(intersection(arc.p, arc.next.p, l*2))
        end
        arc = arc.next
    end
end

--------------------------------------------------------------------------------

local function liang_barsky (p1_x, p1_y, p2_x, p2_y, borders)
    -- Cuts off a line to fit within a bounding box.
    -- @param p1_x The x coordinate of the first point.
    -- @param p1_y The y coordinate of the first point.
    -- @param p2_x The x coordinate of the second point.
    -- @param p2_y The y coordinate of the second point.
    -- @param borders A list of bounding boxes.
    -- @return number x coordinate of the first point within the box.
    -- @return number y coordinate of the first point within the box.
    -- @return number x coordinate of the second point within the box.
    -- @return number y coordinate of the second point within the box.

    local t1, t2 = 0, 1
    local dx, dy = p2_x-p1_x, p2_y-p1_y

    for border = 1, 4 do
        local p, q = 0, borders[border]
        if border == 1 then
            p, q = -dx, -(q-p1_x)
        elseif border == 2 then
            p, q =  dx,  (q-p1_x)
        elseif border == 3 then
            p, q = -dy, -(q-p1_y)
        elseif border == 4 then
            p, q =  dy,  (q-p1_y)
        end

        if p==0 and q < 0 then
            return nil
        end

        local r = q/p
        if p < 0 then
            if r > t2 then
                return nil
            elseif r > t1 then
                t1 = r
            end
        elseif p > 0 then
            if r < t1 then
                return nil
            elseif r < t2 then
                t2 = r
            end
        end
    end

    return p1_x + t1*dx, p1_y + t1*dy, p1_x + t2*dx, p1_y + t2*dy
end



local function cut_edges (edges, border_left, border_right, border_top, border_bottom)
    -- Cuts of edges to fit within a bounding box.
    -- @param edges A list of edges to cut.
    -- @param border_left The minimum x of the box.
    -- @param border_right The maximum x of the box.
    -- @param border_top The minimum y of the box.
    -- @param border_bottom The maximum y of the box.

    local atan2 = math.atan2

    local borders = {border_left, border_right, border_bottom, border_top}
    local boundary_points = {}
    local center_x, center_y = (border_left+border_right)/2, (border_bottom+border_top)/2
    for i=#edges, 1, -1 do
        local edge = edges[i]
        local p1, p2 = edge.p1, edge.p2
        local n1_x, n1_y, n2_x, n2_y = liang_barsky(p1.x, p1.y, p2.x, p2.y, borders)
        if not n1_x then
            table.remove(edges,i)
        elseif p1.x ~= n1_x and p1.y ~= n1_y then
            edge.p1 = new_point(n1_x,n1_y)
            edge.p1.r = atan2(n1_x-center_x,n1_y-center_y)
            table.insert(boundary_points, edge.p1)
        elseif p2.x ~= n2_x and p2.y ~= n2_y then
            edge.p2 = new_point(n2_x,n2_y)
            edge.p2.r = atan2(n2_x-center_x,n2_y-center_y)
            table.insert(boundary_points, edge.p2)
        end
    end

    local corner_angles = {
        math.pi,
        math.atan2(border_right-center_x,border_bottom-center_y),   -- Top Right
        math.atan2(border_right-center_x,border_top-center_y),      -- Bottom Right
        math.atan2(border_left-center_x,border_top-center_y),       -- Bottom Left
        math.atan2(border_left-center_x,border_bottom-center_y),    -- Top Left
    }
    local next_angel = table.remove(corner_angles)

    table.sort(boundary_points,function(a,b) return a.r < b.r end)
    local min, max = math.min, math.max
    for i=1, #boundary_points do
        local point_1, point_2 = boundary_points[i], boundary_points[i%#boundary_points+1]
        if next_angel < point_2.r then
            local corner_id = #corner_angles
            local new_point = new_point(
                corner_id<3 and max(point_1.x,point_2.x) or min(point_1.x,point_2.x),
                (corner_id==2 or corner_id==3) and max(point_1.y,point_2.y) or min(point_1.y,point_2.y)
            )
            table.insert(edges,{p1=point_1,p2=new_point})
            table.insert(edges,{p1=point_2,p2=new_point})
            next_angel = table.remove(corner_angles) or 5
        else
            table.insert(edges,{p1=point_1,p2=point_2})
        end
    end
end

voronoi.fortunes_algorithm = function (start_points, p1_x, p1_y, p2_x, p2_y)
    -- Finds the edges of a voronoi graph.
    -- @param start_points Points to generate the graph from.
    -- @param p1_x The minimum x of the box.
    -- @param p1_y The minimum y of the box.
    -- @param p2_x The maximum x of the box.
    -- @param p2_y The maximum y of the box.
    -- @return sequence<Edge> The edges of the voronoi graph.

    local points_and_events = Heap.new()
    local output = {}

    for _, point in ipairs(start_points) do
        points_and_events:insert(point)
    end

    local root_point = points_and_events:pop()
    local root = new_arc(root_point)

    while not points_and_events:empty() do
        local point_or_event = points_and_events:pop()
        if point_or_event.valid == nil then -- It's a point
            front_insert(point_or_event,root,output, points_and_events)
        elseif point_or_event.valid then -- It's an event
            process_event(point_or_event,output, points_and_events)
        end
    end

    finish_edges(root, p1_x, p1_y, p2_x, p2_y)

    cut_edges(output, p1_x, p2_x, p2_y, p1_y)

    return output
end

--------------------------------------------------------------------------------
-- Face / Polygon Finding

local function do_points_curve_left (p1, p2, p3)
    -- Checks whether three points curve towards the left.
    -- @param p1 The first Point.
    -- @param p2 The second Point.
    -- @param p3 The third Point.
    -- @return boolean Whether they do or not.

	return (p2.x-p1.x)*(p3.y-p1.y) - (p2.y-p1.y)*(p3.x-p1.x) < 0
end

local function angle_between_three_points ( p1, p2, p3 )
    -- Finds the angle between three points.
    -- @param p1 The first Point.
    -- @param p2 The second Point.
    -- @param p3 The third Point.
    -- @return number The angle in radians.

	local A = math.sqrt(math.pow(p1.x-p2.x,2) + math.pow(p1.y-p2.y,2))
	local B = math.sqrt(math.pow(p2.x-p3.x,2) + math.pow(p2.y-p3.y,2))
	local C = math.sqrt(math.pow(p3.x-p1.x,2) + math.pow(p3.y-p1.y,2))
	local angle_c = math.acos( ( A*A + B*B - C*C ) / ( 2 * A * B ) )
	if not do_points_curve_left(p1, p2, p3 ) then
		angle_c = ( 2 * math.pi ) - angle_c
	end
	return angle_c == angle_c and angle_c or math.pi
end

local function dist_point_to_edge (point, edge)
    -- Finds the distance between a point and the closest point on the edge.
    -- @param point The Point.
    -- @param edge The Edge.
    -- @return number The distance.

	local x, y				= 0, 0
	local x1, y1, x2, y2	= edge.p1.x, edge.p1.y, edge.p2.x, edge.p2.y
	local x3, y3			= point.x, point.y
	local unclamped_u = ( (x3-x1)*(x2-x1) + (y3-y1)*(y2-y1) ) /
                        ( (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) )
	local u = math.min( 1, math.max( 0, unclamped_u ) )
	local closest_x = x1 + u*(x2-x1)
	local closest_y = y1 + u*(y2-y1)

	return math.sqrt( math.pow(point.x-closest_x,2) +
                      math.pow(point.y-closest_y,2))
end

local function get_closest_edges (point, edges)
    -- Finds the edge that is closest to a point.
    -- @param point Point to find Edges from.
    -- @param edges The list of Edges to check through.
    -- @return Edge The nearest edge.
    -- @return number The distance.

	local closest_edge, edge_dist = nil, math.huge

	for _, line in ipairs( edges ) do
		local dist = dist_point_to_edge( point, line )
		if dist < edge_dist then
			closest_edge, edge_dist = line, dist
		end
	end

	return closest_edge, edge_dist
end

local function construct_point_relations (edges)
    -- Creates a special structure where it's easy to find relations between
    -- points.
    -- @param edges A list of edges to construct the relation from.
    -- @return PointRelation The relation object.

	local point_rel = {}
	for _, edge in ipairs(edges) do
	    if not point_rel[edge.p1] then
	        point_rel[edge.p1] = {}
	    end
	    table.insert(point_rel[edge.p1],edge.p2)
	    if not point_rel[edge.p2] then
	        point_rel[edge.p2] = {}
	    end
	    table.insert(point_rel[edge.p2],edge.p1)
	end
	return point_rel
end

local function find_next_point (prev_point, head_point, is_left_side, point_rel)
    -- Finds the next point of the face.
    -- @param prev_point The Point that was previously operated on.
    -- @param head_point The Point that was just operated on.
    -- @param is_left_side Whether the face is rotating left or right.
    -- @param point_rel The PointRelation object.
    -- @return Point The next Point.

	local next_point = nil
	local next_angle = is_left_side and math.huge or 0

	for _, other_point in ipairs( point_rel[head_point] or {} ) do
		if other_point ~= prev_point then
			local angle = angle_between_three_points(prev_point, head_point, other_point )
			if (is_left_side and angle<next_angle) or (not is_left_side and angle>next_angle) then
				next_point, next_angle = other_point, angle
			end
		end
	end
	return next_point
end

local function find_face_for_point ( point, edges, point_rel )
    -- Finds the face which is generated from some point.
    -- @param point Point find face from.
    -- @param edges A list of Edges to look through for the face.
    -- @param point_rel A PointRelation object to operate on.
    -- @return Face|nil A face object if any is found.

	local closest_edge =  get_closest_edges(point, edges)
	local start_point = closest_edge.p1
	local head_point = closest_edge.p2
	local prev_point = start_point
	local is_left_side = do_points_curve_left(closest_edge.p1, closest_edge.p2, point)

	local face = { start_point, head_point }
	local Attempts = 10000

	while true and Attempts > 0 do
		local next_point = find_next_point(prev_point, head_point, is_left_side, point_rel )
		if next_point == start_point or not next_point then
			break
		else
			table.insert( face, next_point )
			prev_point, head_point = head_point, next_point
		end
		
		Attempts = Attempts - 1
	end

	if #face > 2 then
		return face
	end
end

voronoi.find_faces_from_edges = function(edges, points)
    -- Finds the faces containing Points.
    -- @param edges The Edges of the graph to look within.
    -- @param points The Points to find faces for.
    -- @return sequence<Face> A list of found Faces.

	local point_rel = construct_point_relations(edges)
	local faces = {}
	for _, point in ipairs( points ) do
		local new_face = find_face_for_point( point, edges, point_rel )
		table.insert(faces, new_face)
	end
	return faces
end

