local fpsGraph = {}

fpsGraph.fpsFont = love.graphics.newFont(8)

-- creates a graph table (too lazy to make objects and stuff)
function fpsGraph.createGraph(x, y, width, height, delay, draggable)
	local vals = {}
	for i=1, math.floor((width or 50)/2) do
		table.insert(vals, 0)
	end
	return {
		x = x or 0,
		y = y or 0,
		width = width or 50,
		height = height or 30,
		delay = delay or 0.5,
		draggable = draggable or true,
		vals = vals,
		vmax = 0,
		cur_time = 0,
		label = "graph",
		_dx = 0,
		_dy = 0,
		_isDown = false
	}
end

function fpsGraph.updateGraph(graph, val, label, dt)
	graph.cur_time = graph.cur_time + dt
	local mouseX, mouseY = love.mouse.getPosition()

	if graph.draggable then
		if (mouseX < graph.width+graph.x and mouseX > graph.x and
		   mouseY < graph.height+graph.y and mouseY > graph.y) or graph._isDown then
			if love.mouse.isDown("l") then
				graph._isDown = true
				graph.x = mouseX - graph._dx
				graph.y = mouseY - graph._dy
			else
				graph._isDown = false
				graph._dx = mouseX - graph.x
				graph._dy = mouseY - graph.y
			end
		end
	end

	while graph.cur_time >= graph.delay do
		graph.cur_time = graph.cur_time - graph.delay

		table.remove(graph.vals, 1)
		table.insert(graph.vals, val)

		local max = 0
		for i=1, #graph.vals do
			local v = graph.vals[i]
			if v > max then
				max = v
			end
		end
		graph.vmax = max
		graph.label = label
	end
end

function fpsGraph.updateFPS(graph, dt)
	local fps = 0.75*1/dt + 0.25*love.timer.getFPS()

	fpsGraph.updateGraph(graph, fps, "FPS: " .. math.floor(fps*10)/10, dt)
end

function fpsGraph.updateMem(graph, dt)
	local mem = collectgarbage("count")

	fpsGraph.updateGraph(graph, mem, "Memory (KB): " .. math.floor(mem*10)/10, dt)
end

-- draws all the graphs in your list
function fpsGraph.drawGraphs(graphs)
	love.graphics.setFont(fpsGraph.fpsFont)
	for j=1, #graphs do
		local v = graphs[j]
		local maxVal = math.ceil(v.vmax/10)*10+20
		local len = #v.vals
		local step = v.width/len
		for i=2, len do
			local a = v.vals[i-1]
			local b = v.vals[i]
			love.graphics.line(step*(i-2)+v.x, v.height*(-a/maxVal+1)+v.y,
							   step*(i-1)+v.x, v.height*(-b/maxVal+1)+v.y)
		end
		love.graphics.print(v.label, v.x, v.height+v.y-8)
	end
end

return fpsGraph