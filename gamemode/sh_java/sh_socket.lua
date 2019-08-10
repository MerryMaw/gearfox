
/* 
	Creating a wrapper, without the need of third party modules such as Bromsocket. 
	
	We already know that Websockets work on clientside using Javascript, however
	serversided, we can't really execute any Javascript code. Therefore, we will 
	use http.fetch and post to do serversided authentication and send it back to 
	the clients websockets for further calls. (We cannot rely on clients only 
	for security reasons)
	
	
	WORK-IN-PROGRESS:
*/

JNet = {}
JNet.ListenEvents = {}

local host = ""

function JNet.SetServerHost(hostName)
	host = hostName
end


function JNet.Send(event,data)
	local res = {}
	local dat = {event = event,data = data}
	
	http.Post(host,dat,
		function(r,r_len,r_headers,r_status) 
			if (res.OnSuccess) then res.OnSuccess(r,r_len,r_headers,r_status) end 
		end,
		function(r) 
			if (res.OnFailure) then res.OnFailure(r) end 
		end
	)
	
	return res
end

function JNet.AddListenEvent(event,func)
	JNet.ListenEvents[event] = func
end

/*
hook.Add("Tick","gf_socklisteners",function()

end)
*/

