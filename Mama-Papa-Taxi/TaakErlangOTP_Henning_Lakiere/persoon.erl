%Personen kunnen afspraken maken die voor alle personen in een aparte ets tabel worden opgeslagen

-module(persoon).
-export([start/0, init/0, loop/1, add_afspraak/2]).

start() ->
	survivor:log(process_info(self(), current_function)),
	Pid = spawn(?MODULE, init, []).

init() ->
	survivor:log(process_info(self(), current_function)),
	Lijst_afspraken = ets:new(afspraken, [ordered_set]),
	loop(Lijst_afspraken).


add_afspraak(Lijst_afspraken, {Start, Eind, Detail, Plaats}) ->
	survivor:log(process_info(self(), current_function)),
	ets:insert(Lijst_afspraken, {{Start, make_ref()}, Eind, Detail, Plaats}).

loop(Lijst_afspraken) ->
	receive
		{add_afspraak, {Start, Eind, Detail, Plaats}} ->
			?MODULE:add_afspraak(Lijst_afspraken, {Start, Eind, Detail, Plaats}),
			?MODULE:loop(Lijst_afspraken);
		stop -> ok
	end.