





pcall(require,"tmysql4")
	
mysql = {}

if (tmysql) then 
	--tmysql4 support. Doesn't have memory leaks so we prioritise this module over mysqloo
	
	function mysql:Start(Host,User,Pass,Database,Port)
		local db,err = tmysql.initialize(Host,User,Pass,Database,Port,nil,CLIENT_MULTI_STATEMENTS)
		if (err) then ErrorNoHalt( "Connection failed: "..err.."\n" ) end
		return db
	end
	
	function mysql:Query(DAT,DB)
		local db = DB or nil
		if (!db) then Msg( "Database does not exist. Call mysql:Start()\n" ) return end
		
		local QUERY = {}
		QUERY.RowsAffected = 0
		
		function QUERY:affectedRows()
			return self.RowsAffected
		end
		
		--MsgN(os.date().." - Query: "..DAT)
		
		db:Query(DAT,function(Q,ResultsObj)
			for ResultID,results in pairs(ResultsObj) do
				if (results.status) then
					Q.RowsAffected = results.affected
					
					if (Q.onData) then
						for k,v in pairs(results.data) do
							Q.onData(Q,v,ResultID)
						end
					end
					
					if (Q.onSuccess) then
						Q.onSuccess(Q,results.data,ResultID)
					end
				else
					if (Q.onError) then
						Q.onError(Q,results.error,ResultID)
					end
				end
			end
			
			if (Q.onCompleted) then Q.onCompleted(Q,ResultsObj) end
		end," ",QUERY)
		
		function QUERY.onError(s,er) ErrorNoHalt( "Query Error: "..er.."\n"..DAT.."\n" ) end
		function QUERY.onFailure(s,er) ErrorNoHalt( "Query Failure: "..er.."\n"..DAT.."\n" ) end
		
		return QUERY
	end
	
	return --Lets not load MySQLoo bullcrap in
else
	Msg("--- tmysql Module not found! Testing for MySQLoo module---\n")
end


--MySQLoo support. 
pcall(require,"mysqloo")

if (!mysqloo) then Msg("--- MySQLoo Module not found! ---\n") return end

mysql = {}

local IsTestingConnection = false

function mysql:TestDB(db,iRetryNum)
	if (IsTestingConnection and !iRetryNum) then return end
	IsTestingConnection = true
	
	iRetryNum = iRetryNum or 4
	if (!db) then return end
	
	if (db:status() == mysqloo.DATABASE_NOT_CONNECTED and iRetryNum > 0) then 
		Msg( "Reconnecting...\n" ) 
		db:connect() 
		timer.Simple(5,function() self:TestDB(db,iRetryNum-1) end)
	else
		IsTestingConnection = false
	end
end

function mysql:StartSimple(Host,User,Pass,Database,Port)
	local db = mysqloo.connect(Host,User,Pass,Database,Port)
	function db.onConnectionFailed(self,er) ErrorNoHalt( "Connection failed: "..er.."\n" ) end
	function db.onConnected(self) Msg( "Connection has been established.\n" ) end
	db:connect()
	return db
end

function mysql:Start(Host,User,Pass,Database,Port,Socket,Flags)
	local db = mysqloo.connect(Host,User,Pass,Database,Port,Socket,Flags)
	function db.onConnectionFailed(self,er) ErrorNoHalt( "Connection failed: "..er.."\n" ) end
	function db.onConnected(self) Msg( "Connection has been established.\n" ) end
	db:connect()
	return db
end
	
function mysql:Query(DAT,DB)
	local db = DB or nil
	if (!db) then Msg( "Database does not exist. Call mysql:Start()\n" ) return end
	
	local DATABASE = db:query(DAT)
	if (DATABASE) then
		function DATABASE.onError(s,er) ErrorNoHalt( "Query Error: "..er.."\n" ) self:TestDB(DB) end
		function DATABASE.onFailure(s,er) ErrorNoHalt( "Query Failure: "..er.."\n" ) self:TestDB(DB) end
		DATABASE:start()
	end
	return DATABASE
end
