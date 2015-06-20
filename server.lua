
require "enet"

server = {}
server.host = nil
server.event = nil
server.desenho_recebido = ''
server.started = false

function server:start(ip, peer_c)
	ip = ip or "localhost:8080"
	
	peer_c = peer_c or 64
	if peer_c == 0 then
		peer_c = 64
	end
	self.host = enet.host_create(ip, peer_c)
	if not self.host then
		return false
	end
	self.event = self.host:service(100)
	self.started = true
	return true
end

function server:isStarted()
	return self.started
end



function server:run_server()
	
	self.event = self.host:service(5)
	if self.event then
		if self.event.type == 'connect' then
			--enviamos tudo, mesmo o que já foi "salvo"
			_desenho_geral = desenho:codificar(controller.storage)
			self.event.peer:send(_desenho_geral)
			controller.peersconected = controller.peersconected + 1
		end
		if self.event.type == 'receive' then
			if self.event.data == '1111111111' then
				controller.peersconected = controller.peersconected - 1
				self.event.peer:send('1111111111')
				return
			end
			local receivetype = nil
			--_desenho_geral = _desenho_geral .. self.event.data
			local r = nil

			--se event.data tem mais de 30 digitos é por que representa uma table de riscos
			if #self.event.data > 30 then
				r = controller:decodificar(self.event.data)
				receivetype = 'table'
			--se tem 30 ou menos é porque representa um risco unitário
			elseif #self.event.data <= 30 then
				r = controller:decodificar_unit(self.event.data)
				receivetype = 'unit'
			end
			if #self.event.data > 0 and r ~= nil and r ~= {} then
				if receivetype == 'table' then
					--colocamos cada risco não repetido na cadeia
					for i = 1, #r, 1 do
						if not controller:buscarRiscoRepetido(r[i]) then
							table.insert(controller.cadeia, r[i])
						end
					end
				elseif not controller:buscarRiscoRepetido(r) then
					table.insert(controller.cadeia, r)
				end
			end

			if controller.idofsent < #controller.cadeia then
				controller.pacoteParaEnviar = desenho:codificar_by_range(controller.idofsent + 1, #controller.cadeia)
			end
			controller.idofsent = #controller.cadeia
			--self.event.peer:send(controller.pacoteParaEnviar)
			
			--servidor envia tudo, os clientes controlam as repetições
			_desenho_geral = desenho:codificar(controller.cadeia)
			controller.test = #controller.cadeia
			self.event.peer:send(_desenho_geral)
			
			--fim do test

			controller.pacoteParaEnviar = ''
			_desenho_local = ''
		end
	end
end

function server:getDesenho()
	return self.desenho_recebido
end

function server:close()
	self.host = nil
	collectgarbage()
end