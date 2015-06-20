menu = {}
menu.x_position = 100
menu.options = {
	botao:new({text = "Criar Sala", x = menu.x_position, y = _ty/2 - myfont:getHeight()*2, execute = function() layer = 'ip_selection' end}),
	botao:new({text = "Entrar em Sala", x = menu.x_position,  y = _ty/2 - myfont:getHeight(), execute = function() layer = 'ip_choose' end}),
	botao:new({text = "Sair", x = menu.x_position,  y = _ty/2, execute = love.event.quit})
}

function menu:update()
	for i, j in ipairs(self.options) do
		j:check_hl(love.mouse.getX(), love.mouse.getY())
	end
	self:execute_option(self:search_clicked_option())
end

function menu:execute_option(i)
	if i > 0 then
		self.options[i]:execute()
	end
end

function menu:search_clicked_option()
	for i, j in ipairs(self.options) do
		if j.clicked then
			return i
		end
	end
	return 0
end

function menu:check_option(released)
	for i, j in ipairs(self.options) do
		if j.hl and not released then
			j.clicked = true
		end
		if released then
			for i, j in ipairs(self.options) do
				j.clicked = false
			end
		end
	end
end

function menu:draw()
	for i, j in ipairs(self.options) do
		j:draw()
	end
end
