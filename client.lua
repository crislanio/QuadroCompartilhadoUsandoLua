
require 'enet'

client = {}
client.host = nil
client.server = nil
client.event = nil
client.created = false
client.connected = false
client.desconect_flag = false
function client:run_client()

	self.event = self.host:service(5)
	if self.event then
		if self.event.type == 'connect' then
			_desenho_geral = self.event.data
			self.event.peer:send(_desenho_local)
		end
		if self.event.type == "receive" then
			if self.event.data == '1111111111' then
				_deseconectado_pode_sair_com_calma = true
				return
			end
			if self.desconect_flag then
				self.event.peer:send('1111111111')
			end
			local receivetype = nil
			--_desenho_geral = _desenho_geral .. self.event.data
			local r = nil
			if #self.event.data > 30 then
				r = controller:decodificar(self.event.data)
				receivetype = 'table'
			elseif #self.event.data <= 30 then
				r = controller:decodificar_unit(self.event.data)
				receivetype = 'unit'
			end

			if #self.event.data > 0 and r ~= nil and r ~= {} then
				if receivetype == 'table' then
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
			self.event.peer:send(controller.pacoteParaEnviar)
			controller.pacoteParaEnviar = ''
			_desenho_local = ''
		end
		

	end
	
end

function client:desconectar()
	self.desconect_flag = true
end

function client:getAllIps()


end

function client:createIpChooseList()



end

function client:create(ip)
	self.host = enet.host_create()
	self.server = self.host:connect(ip)
	if not self.server then
		return false
	end
	self.created = true
	return true
end

function client:close()
	self.host = self.host:connect("0.0.0.0:8000")
	self.host = nil
	collectgarbage()
end