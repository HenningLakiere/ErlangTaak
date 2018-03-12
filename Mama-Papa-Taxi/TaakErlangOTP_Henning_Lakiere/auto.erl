-module(auto).
-export([start/0, init/0, loop/1, reserveer/2]).

start() ->
	survivor:log(process_info(self(), current_function)),
	(whereis(auto_manager) =:= undefined) andalso (auto_manager:start()),
	Pid = spawn(?MODULE, init, []).

init() ->
	survivor:log(process_info(self(), current_function)),
	Lijst_reservaties = ets:new(reservaties, [ordered_set]),
	whereis(auto_manager) ! {add_auto, {self(), Lijst_reservaties}},
	loop(Lijst_reservaties).

reserveer(Lijst_reservaties, {Persoon_pid, Start, Eind}) ->
	survivor:log(process_info(self(), current_function)),
	ets:insert(Lijst_reservaties, {Start, Eind, Persoon_pid(make_ref())}).

loop(Lijst_reservaties) ->
    receive
		{reserveer, {Persoon_pid, Start, Eind}} ->
			?MODULE:reserveer(Lijst_reservaties, {Persoon_pid, Start, Eind}),
			?MODULE:loop(Lijst_reservaties);
		stop -> ok
    end.