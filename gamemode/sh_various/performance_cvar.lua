
--Recommend sv_turbophysics 1 for cheap physics.
--cl_threaded_bone_setup 1
--cl_threaded_client_leaf_system 1
--r_threaded_client_shadow_manager
--r_threaded_particles 1
--r_threaded_renderables 1
--r_queued_ropes 1
--studio_queue_mode 1
--gmod_mcore_test 1
--host_thread_mode 2

concommand.Add("gf_config",function(pl,cmd,arg)
	local b = tobool(arg[1]) and 1 or 0
	
	pl:ConCommand("cl_threaded_bone_setup " .. b)
	pl:ConCommand("cl_threaded_client_leaf_system " .. b)
	pl:ConCommand("r_threaded_client_shadow_manager " .. b)
	pl:ConCommand("r_threaded_particles " .. b)
	pl:ConCommand("r_threaded_renderables " .. b)
	pl:ConCommand("r_queued_ropes " .. b)
	pl:ConCommand("studio_queue_mode " .. b)
	pl:ConCommand("gmod_mcore_test " .. b)
end)