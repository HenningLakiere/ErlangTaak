-module(autoManager).

-export([start/0, init/0, loop/1, add/2, getReservaties/3, getBeschikbareWagens/2, vergelijkTijd/3, stop/0]).

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

%B = begintijd
%E = eindtijd

getBeschikbareWagens(B, E) ->
	%get tabellen ID's
	Tids = ets:match(wagens, {{'_', '_'}, '$2', '_', '_'}),
	getReservaties(Tids, B, E).

getReservaties([], _, _) -> [];
getReservaties([Tid|S], B, E) ->
	Reservaties = ets:match(lists:nth(1,Tid), {{'$1', '_'}, '$2', '_', '_'}),
	case vergelijkTijd(Reservaties, B, E) of
		true -> 
			%get auto name
			Name = getProcesName(ets:info(lists:nth(1,Tid), owner)),
			[Name | getReservaties(S, B, E)];
		false -> 
			getReservaties(S, B, E)
	end.

vergelijkTijd([], _, _) -> true;
vergelijkTijd([X|XS], Y, Z) -> 
	case ((lists:nth(1,X) =< Y) andalso (lists:nth(2,X) >= Y))
		orelse ((lists:nth(1,X) =< Z) andalso (lists:nth(2,X) >= Z)) of
		true ->
			false;
		_->
			vergelijkTijd(XS, Y, Z)
	end.

getProcesName(Pid) ->
	{_, Name} = erlang:process_info(Pid, registered_name),
	Name.

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
		{getBeschikbareWagens, {B, E}} ->
			?MODULE:getBeschikbareWagens(B, E),
			?MODULE:loop(Wagens);
		_->
			io:format("Niet herkende opdracht, probeer opnieuw!"),
			loop(Wagens)
	end.
