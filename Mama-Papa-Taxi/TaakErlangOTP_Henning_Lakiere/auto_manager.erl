-module(auto_manager).
-export([start/0, init/0, loop/0, add_auto/1]).

start() ->
	survivor:log(process_info(self(), current_function)),
	Pid = spawn_link(?MODULE, init, []),
	register(auto_manager, Pid).

init() ->
	survivor:log(process_info(self(), current_function)),
	ets:new(auto_table, [ordered_set, public, named_table]),
	loop().

add_auto({Pid, Tid}) ->
	survivor:log(process_info(self(), current_function)),
	ets:insert_new(auto_table, {Pid, Tid, element(2, process_info(Pid, registered_name))}).

loop() ->
	receive
		{add_auto, {Pid, Tid}} ->
			?MODULE:add_auto({Pid, Tid}),
			?MODULE:loop();
		stop -> ok
	end.