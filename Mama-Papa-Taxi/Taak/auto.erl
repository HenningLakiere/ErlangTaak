-module(auto).
-export([new/0, init/0, maakReservering/2, volgendeReservering/1, loop/1, destroy/1]).

%spawn nieuwe auto Pid
new() ->
	Pid = spawn(?MODULE, init, []),
	Pid.

%initiëren van auto ets tabel en loop beginnen
init() ->
	Reserveringen = ets:new(reserveringen, [ordered_set, public]),
	whereis(autoManager) ! {add, {self(), Reserveringen, 0, false}},
	%
	maakReservering(Reserveringen, {infinity, infinity, unknown,destroy}),
	loop(Reserveringen).

destroy(Reserveringen) ->
	ets:delete(Reserveringen),
	{stop}.

maakReservering(Reserveringen, {infinity, infinity, P, D}) ->
	ets:insert(Reserveringen, {{infinity, make_ref()}, infinity, P, D});

maakReservering(Reserveringen, {B, E, P, D})
	when 
		is_integer(B) 
	and 
		is_integer(E)
	%and
	%	is_atom(P)
	and
		is_atom(D)
	->
	ets:insert(Reserveringen, {{B, make_ref()}, E, P, D}).
	%eventManager:post({B, activiteit, testActiviteit, [self(), B, E, P, D]}).

volgendeReservering(Reserveringen) ->
	Key = ets:first(Reserveringen),
	[{{B, _}, E, P, D}] = ets:lookup(Reserveringen, Key),
	Name = getProcesName(),
	Persoon = getProcesName(P),
	io:format("De volgende reservatie voor: ~p~nDoel: ~p~nvan ~p tot ~p~ndoor: ~p", [Name, D, B, E, Persoon]).

getProcesName() ->
	{_, Name} = erlang:process_info(self(), registered_name),
	Name.

getProcesName(Pid) ->
	{_, Name} = erlang:process_info(Pid, registered_name),
	Name.

loop(Reserveringen) ->
	receive
		{maakReservering, {B, E, P, D}} ->
			?MODULE:maakReservering(Reserveringen, {B, E, P, D}),
			?MODULE:loop(Reserveringen);
		{volgendeReservering} ->
			?MODULE:volgendeReservering(Reserveringen),
			?MODULE:loop(Reserveringen);
		_ ->
			io:format("Niet herkende opdracht, probeer opnieuw!"),
			loop(Reserveringen)
	end.

