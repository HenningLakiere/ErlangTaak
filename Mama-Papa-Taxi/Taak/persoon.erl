-module(persoon).

-export([new/0, init/0, loop/1, die/1]).
-export([maakAfspraak/2, volgendeAfspraak/1, cancelVolgendeAfspraak/1, cancelVolgendeAfspraak/2, cancelAfspraak/2]).

new() ->
	Pid = spawn(?MODULE, init, []),
	Pid.

init() ->
	Afspraken = ets:new(afspraken, [ordered_set, public]),
	maakAfspraak(Afspraken, {infinity, infinity, die, false}),
	loop(Afspraken).

die(Afspraken) ->
	ets:delete(Afspraken),
	{stop}.

% B = begintijd afspraak
% E = eindtijd afspraak
% D = doel
% A = auto true/false

maakAfspraak(Afspraken, {infinity, infinity, D, A}) ->
	ets:insert(Afspraken, {{infinity, make_ref()}, infinity , D, A});

maakAfspraak(Afspraken, {B, E, D, A})
	when
		is_integer(B) 
	and 
		is_integer(E)
	and
		is_atom(D)
	and
		is_boolean(A)
	->
	ets:insert(Afspraken, {{B, make_ref()}, E , D, A}),
	eventManager:post({B, activiteit, testActiviteit, [self(), B, E, D, A]}),
	eventManager:deletePost({E, persoon, cancelVolgendeAfspraak, [Afspraken, self()]}).

volgendeAfspraak(Afspraken) ->
	Key = ets:first(Afspraken),
	[{{B, _ }, E, D, A}] = ets:lookup(Afspraken, Key),
	Name = getProcesName(),
	Auto = if
		A ->
			een;
		true ->
			geen
	end,
  	io:format("~p's volgende afspraak is: ~p~nvan ~p tot ~p~nHij/Zij heeft hiervoor ~p auto nodig~n", [Name, D, B, E, Auto]).

cancelVolgendeAfspraak(Afspraken) ->
	Key = ets:first(Afspraken),
	[{{Time, _}, E, D, _}] = ets:lookup(Afspraken, Key),
	Name = getProcesName(),
	io:format("~p cancelled volgende afspraak: ~p en is terug beschikbaar tussen ~p en ~p~n", [Name, D, Time, E]),
	ets:delete(Afspraken, Key).

cancelVolgendeAfspraak(Afspraken, Pid) ->
	Key = ets:first(Afspraken),
	[{{_, _}, _, D, _}] = ets:lookup(Afspraken, Key),
	Name = getProcesName(Pid),
	io:format("~p is klaar met ~p~n", [Name, D]),
	ets:delete(Afspraken, Key).

cancelAfspraak(Afspraken, Time) ->
	[[E, D]] = ets:match(Afspraken, {{Time, '_'}, '$1', '$2', '_'}),
	Name = getProcesName(),
	io:format("~p cancelled afspraak: ~p en is terug beschikbaar tussen ~p en ~p~n", [Name, D, Time, E]),
	ets:match_delete(Afspraken, {{Time, '$1'}, '_', '_', '_'}).

getProcesName() ->
	{_, Name} = erlang:process_info(self(), registered_name),
	Name.
getProcesName(Pid) ->
	{_, Name} = erlang:process_info(Pid, registered_name),
	Name.



loop(Afspraken) ->
	receive
		{maakAfspraak, {B, E, D, A}} ->
			?MODULE:maakAfspraak(Afspraken, {B, E, D, A}),
			?MODULE:loop(Afspraken);
		{volgendeAfspraak} ->
			?MODULE:volgendeAfspraak(Afspraken),
			?MODULE:loop(Afspraken);
		{cancelVolgendeAfspraak} ->
			?MODULE:cancelVolgendeAfspraak(Afspraken),
			?MODULE:loop(Afspraken);
		{cancelAfspraak, B} ->
			?MODULE:cancelAfspraak(Afspraken, B),
			?MODULE:loop(Afspraken);
		_->
			io:format("Niet herkende opdracht, probeer opnieuw!"),
			?MODULE:loop(Afspraken)
	end.


