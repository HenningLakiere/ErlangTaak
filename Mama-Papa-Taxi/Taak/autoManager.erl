-module(autoManager).

-export([start/0, init/0, loop/1, add/2, getReservaties/2, stop/0]).

start() ->
	Pid = spawn(?MODULE, init, []),
	Pid.

init() ->
	Wagens = ets:new(wagens, [ordered_set, public, named_table]),
	loop(Wagens).

%M = Merk
%K = Kilometerstand
%O = Onderhoudstatus

add(Wagens, {Pid, Tid, K, O}) ->
	ets:insert(Wagens, {{Pid, make_ref()}, Tid, K, O}).
	%when
	%	is_atom(M)
	%and
	%	is_integer(K)
	%and
	%	is_boolean(O)
	%->

getReservaties(Wagens, Naam) ->
	Pid = whereis(Naam),
	[[Tid]] = ets:match(Wagens, {{Pid, '_'}, '$1', '_', '_'}),
	[Reservaties] = ets:match(Tid, '$1').
	%Time = 
	%io:format("~p~n", [Reservaties]).

	

stop() ->
	{stop}.

loop(Wagens) ->
	receive
		{add, {Pid, Tid, K, O}} ->
			?MODULE:add(Wagens, {Pid, Tid, K, O}),
			?MODULE:loop(Wagens);
		{getReservaties, Naam} ->
			?MODULE:getReservaties(Wagens, Naam),
			?MODULE:loop(Wagens);
		{getWagens} ->
			io:format("~p~n", [Wagens]),
			?MODULE:loop(Wagens);
		_->
			io:format("Niet herkende opdracht, probeer opnieuw!"),
			loop(Wagens)
	end.
