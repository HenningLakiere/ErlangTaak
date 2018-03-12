% Een autop is een resource
% Een auto kan door een persoon gereserveerd worden van een
% begintijdstip tot een eindtijdstip.
% Om te weten op welke tijdstippen een auto beschibaar/gereserveerd is heeft elke auto 
% zijn eigen ets tabel "Rerservaties"


-module(auto).
-export([start/0, init/0, loop/1, reserveer/2]).

start() ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	(whereis(auto_manager) =:= undefined) andalso (auto_manager:start()),
    Pid = spawn(?MODULE, init, []).

init() ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	% maak voor elke persoon zijn eigen tabel met Reservaties
	Reservaties = ets:new(reservaties, [ordered_set]),
	whereis(auto_manager) ! {add_auto, {self(), Reservaties}},
	loop(Reservaties).

reserveer(Reservaties, {Persoon_pid, Starttijd, Eindtijd}) ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	io:fwrite("\n"), 
	io:fwrite("Autoreservatie wordt nu uitgevoerd: \n"),
	io:fwrite("~p:  van ~p tot ~p -- door ~p \n", [element(2, process_info(self(), registered_name)),
																		Starttijd,
																		Eindtijd,
																		element(2, process_info(Persoon_pid, registered_name))]),
	%event_manager:post({Starttijd, activiteit, test_activiteit, []}),
	
	%ets:insert(Reservaties, {{Persoon_pid, make_ref()}, Starttijd, Eindtijd}).
	ets:insert(Reservaties, {Starttijd, Eindtijd, {Persoon_pid, make_ref()}}).
	
loop(Reservaties) ->
    receive
		{reserveer, {Persoon_pid, Starttijd, Eindtijd}} ->
			?MODULE:reserveer(Reservaties, {Persoon_pid, Starttijd, Eindtijd}),
			?MODULE:loop(Reservaties);
		stop -> ok
    end.
Ä