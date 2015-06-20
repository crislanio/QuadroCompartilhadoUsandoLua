risco = {}
risco.x1 = 0
risco.y1 = 0
risco.x2 = 0
risco.y2 = 0
risco.w = 3
risco.cor = {255, 255, 255}
function risco:new(n)
	n = n or {}
	setmetatable(n, self)
	self.__index = self
	return n
end

function risco:draw()
	--muda a cora para o proximo desenho
	love.graphics.setColor(self.cor)

	--desenho um circulo no comeco do risco e um no final do risco
	love.graphics.circle('fill', self.x1, self.y1, self.w/2)
	love.graphics.circle('fill', self.x2, self.y2, self.w/2)
	
	--define a grossura da linha
	love.graphics.setLineWidth(self.w)

	--desenha a linha
	love.graphics.line(self.x1, self.y1, self.x2, self.y2)
end

desenho = {}
desenho.cadeia = {}

--flag active para controlar o desenho
--se active for True, então o desenho é feito
desenho.active = false

--lastX e lastY deve estar em -1 sempre que vamos começar uma nova cadeia
desenho.lastX = -1
desenho.lastY = -1
desenho.eraseStack = {}
desenho.width = 5
desenho.cor = {255, 255, 255}

function desenho:setcor(cn)
	if cn then
		desenho.cor = name_color(cn)
	end
end

function desenho:changeWidth(d)
	if d == 'wu' then
		self.width = self.width + 1
	elseif d == 'wd' and self.width > 0 then
		self.width = self.width - 1
	end
end
function desenho:catchCursor()
	--pega a posicao atual do cursor
	local x, y = love.mouse.getX(), love.mouse.getY()
	if y > _ty - 50 then
		--eh para nao desenhar na faixa debaixo, onde se seleciona as cores
		return
	end
	-- r = nil, r será o risco que criaremos nesta chamada
	local r = nil

	if self.lastX == -1 or self.lastY == -1 then
		--se esta for a primeira chamada, criamos um um ponto como default
		r = risco:new({x1 = x, y1 = y, x2 = x, y2 = y, w = self.width, cor = self.cor})
	else
		--só entramos aqui se esta não for a primeira chamada
		--aqui criamos um risco com o primeiro ponto no final do ultimo risco
		r = risco:new({x1 = self.lastX, y1 = self.lastY, x2 = x, y2 = y, w = self.width, cor = self.cor})
	end
	--grava a posicao do curso para ajuda no desenho do proximo risco
	self.lastX, self.lastY = x, y


	--SUPER UPAR GAMBIARRA ULTRA
	imagebutton.errormessage01 = ''

	--se o risco for um ponto unico, não guardamos na cadeia
	if r.x1 == r.x2 and r.y1 == r.y2 then
		return
	end
	--precisamos modificar isso aqui
	table.insert(controller.cadeia, r)

	--gravando o momento atual
	_desenho_local = self:codificar_unit(r)
	--_desenho_geral = _desenho_geral .. self:codificar_unit(r)
	

end

function desenho:update()
	if self.active then
		self:catchCursor()
	end
	if love.keyboard.isDown('a') or love.mouse.isDown('l') then
		if not self.active then
			table.insert(self.eraseStack, #self.cadeia + 1)
		end
		self.active = true
		
	else
		self.active = false
		self.lastX, self.lastY = -1, -1
	end
end
function desenho:clear()
	self.cadeia = {}
	self.active = false
	self.lastX = -1
	self.lastY = -1
	self.eraseStack = {}
	self.width = 3
	self.cor = {255, 255, 255}
end

function desenho:erase()
	if #self.eraseStack > 0 then
		local x = self.eraseStack[#self.eraseStack]
		table.remove(self.eraseStack, #self.eraseStack)
		if not self.active then
			while #self.cadeia >= x do
				table.remove(self.cadeia, #self.cadeia)
			end
		end
	elseif #self.cadeia > 0 then
		while #self.cadeia > 0 do
			table.remove(self.cadeia, #self.cadeia)
		end
	end
	
end

function desenho:draw()

end

function desenho:codificar_unit(r)
	if not r then
		return ''
	end
	local s = ''
	s = s .. string.format("%d",r.x1)
	s = s .. '_'
	s = s .. string.format("%d",r.y1)
	s = s .. '_'
	s = s .. string.format("%d",r.x2)
	s = s .. '_'
	s = s .. string.format("%d",r.y2)
	s = s .. '_'
	s = s .. string.format("%d",r.w)
	s = s .. '_'
	s = s .. string.format("%d",r.cor[1])
	s = s .. '_'
	s = s .. string.format("%d",r.cor[2])
	s = s .. '_'
	s = s .. string.format("%d",r.cor[3])
	s = s .. '_'
	s = s .. '#'
	return s
end

function desenho:codificar(cadeia)
	local s = ''
	for i = 1, #cadeia do
		s = s .. self:codificar_unit(cadeia[i])
	end
	return s
end

function desenho:codificar_by_range(start, ending)
	local s = ''
	for i = start, ending do
		--gambiarra das grandes! feche os olhos e o nariz
		s = s .. self:codificar_unit(controller.cadeia[i])
	end
	return s
end

controller = {}
controller.cadeia = {}
controller.storage = {}
controller.screenshot = nil
controller.savedscreen = nil
controller.to_take_screen = false
controller.saved_ss_cont = 0


--PARA O SERVIDOR
controller.idofsent = 0
controller.pacoteParaEnviar = ''
controller.test = 0
controller.peersconected = 0

controller.backgroundimage = nil

imagebutton = botao:new({x = 120, y = _ty - 40, text = 'Abrir Imagem'})
imagebutton.extra_message = 'Digite o caminho da imagem'
imagebutton.recept_path = ''
imagebutton.ativado = false
imagebutton.image = love.graphics.newImage('f.jpg')
imagebutton.success = false
imagebutton.errormessage01 = ''
function imagebutton:ativar()
	self.ativado = true
end
function imagebutton:draw()
	local hue = 200
	if self.hl then
		hue = 255
	end
	love.graphics.setColor(255, 255, 255, hue)
	if self.ativado then
		love.graphics.print(string.format("%s\n%s: %s", self.text, self.extra_message, self.recept_path), self.x, self.y, 0, 0.4, 0.4)
	else
		love.graphics.print(string.format("%s", self.text), self.x, self.y, 0, 0.4, 0.4)
	end
	love.graphics.setColor(255, 0, 0)
	love.graphics.print(self.errormessage01, _tx/2 - 100, _ty/2)
end
function imagebutton:draw_i()
	if self.success then
		love.graphics.draw(self.image)
	end
end
function imagebutton:openimage()
	
	if not love.filesystem.exists(self.recept_path) then
		self.recept_path = ''
		self.errormessage01 = 'caminho invalido'
		return
	end
	self.image = love.graphics.newImage(self.recept_path)
	self.success = true
	self.ativado = false
	self.recept_path = ''
end

local adraw = function(b)
	local c1, c2, c3 = name_color(b.text)[1], name_color(b.text)[2], name_color(b.text)[3]
	local hue = 200
	if b.hl then
		hue = 255
	end
	love.graphics.setColor(c1, c2, c3, hue)
	love.graphics.rectangle('fill', b.x, b.y, 20, 20)
	love.graphics.setColor(255, 255, 255)
end

controller.paleta_cores = {
	botao:new({x = 0, y = _ty - 40, text = 'red', execute = function() desenho:setcor('red') end}, adraw),
	botao:new({x = 20, y = _ty - 40, text = 'orange', execute = function() desenho:setcor('orange') end}, adraw),
	botao:new({x = 40, y = _ty - 40, text = 'yellow', execute = function() desenho:setcor('yellow') end}, adraw),
	botao:new({x = 60, y = _ty - 40, text = 'green', execute = function() desenho:setcor('green') end}, adraw),
	botao:new({x = 60, y = _ty - 20, text = 'ciano', execute = function() desenho:setcor('ciano') end}, adraw),
	botao:new({x = 40, y = _ty - 20, text = 'blue', execute = function() desenho:setcor('blue') end}, adraw),
	botao:new({x = 20, y = _ty - 20, text = 'purple', execute = function() desenho:setcor('purple') end}, adraw),
	botao:new({x = 0, y = _ty - 20, text = 'pink', execute = function() desenho:setcor('pink') end}, adraw),
	botao:new({x = 80, y = _ty - 40, text = 'white', execute = function() desenho:setcor('white') end}, adraw),
	botao:new({x = 80, y = _ty - 20, text = 'black', execute = function() desenho:setcor('black') end}, adraw)
}

function controller:escape()
	local esc = love.window.showMessageBox('Aviso', 'Deseja realmente sair da sala?', {'sim', 'não'})
	if esc == 1 then
		desenho:clear()
		self.cadeia = {}
		layer = 'menu'
	end
end

function controller:decodificar_unit(s)
	if #s == 0 then
		return nil
	end
	local s_table = {}
	local desenho_table = {}
	s:gsub(".", function(c) table.insert(s_table, c) end)
	local temp_table = {}
	local c = ''
	local r = nil
	for i = 1, #s_table do
		if s_table[i] ~= '_' and s_table[i] ~= '#' then
			c = c .. s_table[i]
		elseif s_table[i] == '_' then
			table.insert(temp_table, tonumber(c))
			c = ''
		elseif s_table[i] == '#' then
			r = risco:new({
				x1 = temp_table[1],
				y1 = temp_table[2],
				x2 = temp_table[3],
				y2 = temp_table[4],
				w = temp_table[5],
				cor = {temp_table[6] or 255, temp_table[7] or 255, temp_table[8] or 255} 
				})
		end

	end
	return r

end
function controller:decodificar(s)
	local s_table = {}
	local desenho_table = {}
	s:gsub(".", function(c) table.insert(s_table, c) end)
	local temp_table = {}
	local c = ''
	for i = 1, #s_table do
		if s_table[i] ~= '_' and s_table[i] ~= '#' then
			c = c .. s_table[i]
		elseif s_table[i] == '_' then
			table.insert(temp_table, tonumber(c))
			c = ''
		elseif s_table[i] == '#' then
			table.insert(desenho_table, risco:new({ 
				x1 = temp_table[1],
				y1 = temp_table[2],
				x2 = temp_table[3],
				y2 = temp_table[4],
				w = temp_table[5],
				cor = {temp_table[6] or 255, temp_table[7] or 255, temp_table[8] or 255} 
				}))
			temp_table = {}
		end

	end
	return desenho_table
end
function controller:comparar_riscos(r1, r2)
	if r1.x1 ~= r2.x1 or r1.y1 ~= r2.y1 or r1.x2 ~= r2.x2 or r1.y2 ~= r2.y2 or r1.w ~= r2.w then
		return false
	end
	if r1.cor[1] ~= r2.cor[1] or r1.cor[2] ~= r2.cor[2] or r1.cor[3] ~= r2.cor[3] then
		return false
	end
	return true
end
function controller:buscarRiscoRepetido(r)
	for i = #controller.cadeia, 1, -1 do
		if controller:comparar_riscos(controller.cadeia[i], r) then
			return true
		end
	end
	return false
end

function controller:update()
	desenho:update()

	for i, j in ipairs(self.paleta_cores) do
		j:check_hl(love.mouse.getX(), love.mouse.getY(), 20)
	end
	imagebutton:check_hl(love.mouse.getX(), love.mouse.getY())

	self:execute_option(self:search_clicked_option())
	if imagebutton.clicked then
		imagebutton:ativar()
	end
	if #self.cadeia >= 300 then
		--salvamos todas os riscos para não termos que buscar um por um para imprimir
		--salvamos todos os riscos em uma imageData que fica na memoria RAM
		self:save(1)
	end

end

function controller:checkimagebutton(released)
	if imagebutton.hl and not released then
		imagebutton.clicked = true
	end
	if released then
		imagebutton.clicked = false
	end

end

function controller:save(step)
	if step == 1 then
		self.to_take_screen = true
	elseif step == 2 then
		self.saved_ss_cont = self.saved_ss_cont + 1
		local filename = string.format("Lousa screenshot %d", self.saved_ss_cont)
		self.savedscreen = love.graphics.newImage( self.screenshot)
		for i = 1, #self.cadeia do
			table.insert(self.storage, self.cadeia[i])
		end
		self.cadeia = {}
		self.to_take_screen = false
	end
end

function controller:execute_option(i)
	if i > 0 then
		self.paleta_cores[i]:execute()
	end
end

function controller:search_clicked_option()
	for i, j in ipairs(self.paleta_cores) do
		if j.clicked then
			return i
		end
	end
	return 0
end

function controller:check_color(released)
	for i, j in ipairs(self.paleta_cores) do
		if j.hl and not released then
			j.clicked = true
		end
		if released then
			for i, j in ipairs(self.paleta_cores) do
				j.clicked = false
			end
		end
	end
end

function controller:draw()
	love.graphics.setColor(255, 255, 255)
	imagebutton:draw_i()
	--self.cadeia = self:decodificar(_desenho_geral)
	if self.savedscreen then
		love.graphics.draw(self.savedscreen)
	end
	for i = 1, #self.cadeia do
		self.cadeia[i]:draw()
	end
	if self.to_take_screen then
		self.screenshot = love.graphics.newScreenshot()
		self:save(2)
	end
	love.graphics.setColor(10, 10, 30)
	love.graphics.rectangle('fill', 0, 0, _tx, 30)
	love.graphics.setColor(255, 255, 255)
	if layer == 'server' then
		love.graphics.print(string.format("ip: %s\tcontador de peers: %d", ip_entered, self.peersconected), 0, 0, 0, 0.5, 0.5)
	else
		love.graphics.print(string.format("ip: %s", ip_entered), 0, 0, 0, 0.5, 0.5)
	end
	love.graphics.setColor(10, 10, 30)
	love.graphics.rectangle('fill', 0, _ty - 50, _tx, 50)
	imagebutton:draw()
	for i = 1, #self.paleta_cores do
		self.paleta_cores[i]:draw()
	end
end