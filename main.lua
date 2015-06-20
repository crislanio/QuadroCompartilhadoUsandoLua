function love.load()

	_tx, _ty = 800, 600
	-- love.window.setMode(_tx, _ty)
	myfont = love.graphics.newFont('DK BB.otf', 40)
	love.window.setTitle("Lousa Digital Compartilhada Suprema")
	_desenho_geral = ''
	_desenho_local = ''
	require 'botao'
	require 'lousa'
	require 'server'
	require 'client'
	require 'menu'
	love.mouse.setVisible(false)
	

	--Variaveis para controlar a seleção de IP (tanto no servidor como no cliente)
	ip_entered = ''
	--variavel para o numero maximo de peers (util somente para o servidor)
	max_peers = ''
	--indice da opção que está sendo perguntada no momento
	option_asking = 1
	--numero de opções no total
	options_cont = 2
	--messagem de erro
	errormessage01 = ''

	love.graphics.setFont(myfont)
	layer = 'menu'

	--gambiarra numero 21
	_deseconectado_pode_sair_com_calma = false
end

function love.draw()
	if layer == 'menu' then
		menu:draw()
	elseif layer == 'ip_selection' then -- isso é para o SERVER
		--os dois ifs dentro deste escopo são apenas para realçar a opção atual
		if option_asking == 1 then		
			love.graphics.setColor(255, 255, 255, 255)
		end
		love.graphics.print(string.format("Digite o ip: %s", ip_entered), 50, _ty/2 - 40)
		love.graphics.print("(com a porta)", 50, _ty/2, 0, 0.3, 0.3)
		love.graphics.setColor(255, 255, 255, 200)
		if option_asking == 2 then
			love.graphics.setColor(255, 255, 255, 255)
		end
		love.graphics.print(string.format("Número máximo de peers: %s", max_peers), 50, _ty/2 + 20)
		love.graphics.setColor(255, 0, 0)
		love.graphics.print(errormessage01, 0, 0, 0, 0.4, 0.4)
	elseif layer == 'ip_choose' then --  isso é para o CLIENTE
		love.graphics.print(string.format("Digite o ip para conectar: %s", ip_entered), 50, _ty/2 - 40, 0, 0.6, 0.6)
		love.graphics.print("(com a porta)", 50, _ty/2, 0, 0.3, 0.3)
		love.graphics.setColor(255, 0, 0)
		love.graphics.print(errormessage01, 0, 0, 0, 0.4, 0.4)
	elseif layer == 'server' then
		controller:draw()
	elseif layer == 'client' then
		controller:draw()
	end
	local t = {desenho.cor[1], desenho.cor[2], desenho.cor[3]}

	-- desenhar o mouse
	love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(3)
	love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 3)
	t[4] = 120
	love.graphics.setColor(t)
	love.graphics.setLineWidth(desenho.width/30)
	love.graphics.circle('line', love.mouse.getX(), love.mouse.getY(), desenho.width/2)



end

function love.update()
	
	if layer == 'menu' then
		menu:update()
	elseif layer == 'ip_selection' then
		

	elseif layer == 'server' then

		controller:update()
		server:run_server()
		
	elseif layer == 'client' then
		controller:update()
		client:run_client()
	end

	if _deseconectado_pode_sair_com_calma then
		love.event.quit()
	end

end

function check_ip(ip)
	if ip:sub(1, 10) == "localhost:" then
		local s = ip:sub(11)
		local cont = 0
		while #s > 0 do
			if s:byte() < 48 and s:byte() > 57 then
				return #ip - #s + 1
			end
			cont = cont + 1
			s = s:sub(2)
		end
		if cont <= 4 then
			return -1
		end

	end
	local s = ip
	local bit_cont = 0
	local byte_cont = 1
	local port_cont = -1
	while #s > 0 do
		if port_cont > -1 then
			if s:byte() >= 48 and s:byte() <= 57 then
				port_cont = port_cont + 1
			end
			if port_cont > 4 then
				return #ip - #s + 1
			end
		elseif s:byte() >= 48 and s:byte() <= 57 then
			bit_cont = bit_cont + 1
		elseif s:byte() == 46 then
			if bit_cont < 1 or bit_cont > 3 then
				return #ip - #s + 1
			end
			bit_cont = 0
			byte_cont = byte_cont + 1
		elseif s:byte() == 58 then
			if byte_cont ~= 4 then
				return #ip - #s + 1
			end
			port_cont = 0
		else
			return #ip - #s + 1
		end
		s = s:sub(2)
	end
	if port_cont == 4 then
		return -1
	end
	return #ip - #s + 1

end

function love.textinput(text)
	if layer == 'ip_selection' then
		if option_asking == 1 then
			ip_entered = ip_entered .. text
		elseif option_asking == 2 then
			if (#max_peers == 0 and text:byte() >= 49 and text:byte() <= 57) or (#max_peers > 0 and text:byte() >= 48 and text:byte() <= 57) then
				max_peers = max_peers .. text
			end
		end
	elseif layer == 'ip_choose' then
		ip_entered = ip_entered .. text
	elseif layer == 'server' then
		if imagebutton.ativado then
			imagebutton.errormessage01 = ''
			imagebutton.recept_path = imagebutton.recept_path .. text
		end
	elseif layer == 'client' then
		if imagebutton.ativado then
			imagebutton.errormessage01 = ''
			imagebutton.recept_path = imagebutton.recept_path .. text
		end
	end
end


function love.mousepressed(mx, my, key)

	if layer == 'menu' then
		if key == 'l' then
			menu:check_option()
		end		
	elseif layer == 'server' then
		if key then
			desenho:changeWidth(key)
		end
		controller:check_color()
		controller:checkimagebutton()
	elseif layer == 'client' then
		if key then
			desenho:changeWidth(key)
		end
		controller:check_color()
		controller:checkimagebutton()
	end

	


end

function love.mousereleased(mx, my, key)
	if layer == 'menu' then
		if key == 'l' then
			menu:check_option(true)
		end		
	elseif layer == 'server' then
		controller:check_color(true)
		controller:checkimagebutton(true)
	elseif layer == 'client' then
		controller:check_color(true)
		controller:checkimagebutton(true)
	end



end

function love.keypressed(key)
	if layer == 'menu' then
	
	elseif layer == 'ip_selection' then
		if key == 'return' then
			if option_asking < options_cont then
				option_asking = option_asking + 1
			else
				local cip = check_ip(ip_entered)
				if cip > -1 then
					errormessage01 = string.format("ip %s, erro na posição %d", ip_entered, cip)
					ip_entered = ''
					max_peers = ''
					option_asking = 1
				else
					if server:start(ip_entered, max_peers) then
						layer = 'server'
					else
						errormessage01 = "não foi possivel criar (não sei porque)"
						ip_entered = ''
						max_peers = ''
						option_asking = 1
					end
					
				end
			end
		end
		if key == 'backspace' then
			if option_asking == 1 then
				ip_entered = string.sub(ip_entered,1, #ip_entered - 1)
			elseif option_asking == 2 then
				max_peers = string.sub(max_peers, 1, #max_peers - 1)
			end
		end
	elseif layer == 'ip_choose' then
		if key == 'return' then
			local cip = check_ip(ip_entered)
			if cip > -1 then
				errormessage01 = string.format("ip %s, erro na posição %d", ip_entered, cip)
				ip_entered = ''
			else
				if client:create(ip_entered) then
					layer = 'client'
				else
					errormessage01 = 'não há sala com este ip'
					ip_entered = ''
				end

			end

		end
		if key == 'backspace' then
			ip_entered = string.sub(ip_entered,1, #ip_entered - 1)
		end
	elseif layer == 'desenho' then
		if key == 'z' then
			desenho:erase()
		end
		if key == 'escape' then
			controller:escape()
		end
	elseif layer == 'server' then
		if imagebutton.ativado then
			if key == 'backspace' then
				imagebutton.recept_path = string.sub(imagebutton.recept_path, 1, #imagebutton.recept_path - 1)
			end
			if key == 'return' then
				imagebutton:openimage()
			end
		end
		if key == 's' then
			controller:save(1)
		end
	elseif layer == 'client' then
		if imagebutton.ativado then
			if key == 'backspace' then
				imagebutton.recept_path = string.sub(imagebutton.recept_path, 1, #imagebutton.recept_path - 1)
			end
			if key == 'return' then
				imagebutton:openimage()
			end
		end
		if key == 's' then
			controller:save(1)
		end
		if key == 'escape' then
			client:desconectar()
		end
	end


end

function love.keyreleased(key)



end

function love.quit()
	if layer == 'server' then
		server:close()
	elseif layer == 'local' then
		client:close()
	end
end