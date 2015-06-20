botao = {}
botao.text = ''
botao.x = 0
botao.y = 0
botao.hl = false
botao.clicked = false
botao.alternativedraw = nil
function botao:new(n, draw)
	n = n or {}
	n.alternativedraw = draw or nil
	setmetatable(n, self)
	self.__index = self
	return n
end
function botao:draw()
	if self.alternativedraw then
		self.alternativedraw(self)
	else	
		local off = 0
		local hue = 200
		if self.hl then
			hue = 255
		end
		if self.clicked then
			off = 5
		end
		local twidth_proportion = (myfont:getWidth( self.text ) + off*2)/myfont:getWidth( self.text )
		local theight_proportion = (myfont:getHeight() + off*2)/myfont:getHeight()
		love.graphics.setColor(255, 255, 255, hue)
		love.graphics.print(self.text, self.x - off, self.y - off, 0, twidth_proportion_x, theight_proportion)
	end
end
function botao:check_hl(mx, my, size)
	if not size then
		if mx > self.x and mx < self.x + myfont:getWidth( self.text ) and my > self.y and my < self.y + myfont:getHeight() then
			self.hl = true
		else
			self.hl = false
			self.clicked = false
		end
	else
		if mx > self.x and mx < self.x + size and my > self.y and my < self.y + size then
			self.hl = true
		else
			self.hl = false
			self.clicked = false
		end

	end
end

function botao.execute(self)

end

function name_color(name)
	if name == 'red' then
		return {255, 0, 0}
	end
	if name == 'orange' then
		return {255, 125, 0}
	end
	if name == 'yellow' then
		return {255, 255, 0}
	end
	if name == 'green' then
		return {0, 255, 0}
	end
	if name == 'ciano' then
		return {0, 255, 255}
	end
	if name == 'blue' then
		return {0, 0, 255}
	end
	if name == 'pink' then
		return {255, 0, 255}
	end
	if name == 'purple' then
		return {120, 0, 200}
	end
	if name == 'white' then
		return {255, 255, 255}
	end
	if name == 'black' then
		return {0, 0, 0}
	end
end