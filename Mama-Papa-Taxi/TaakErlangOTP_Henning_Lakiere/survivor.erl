-module(survivor).
-export([start/0, loop/0, log/1]).

start() ->
	spawn(survivor, loop, []).

log(Process_info) ->
	ets:insert(log, {ets:info(log, size), element(2, Process_info)}).

loop() ->
	ets:new(log, [public, ordered_set, named_table]),
	receive
		stop -> ok
	end.