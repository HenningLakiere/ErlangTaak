% Elke persoon heeft zijn eigen ets:tabel met zijn afsppraken

-module(persoon).
-export([start/0, 
			init/0, 
			loop/1, 
			add_afspraak/0, 
			add_afspraak/2, 
			add_afspraak_v2/2, 
			reserveer_auto/1]).

start() ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
    Pid = spawn(?MODULE, init, []).

init() ->
	% maak voor elke persoon zijn eigen tabel met afspraken
	Afspraken = ets:new(afspraken, [ordered_set]),
	loop(Afspraken).

add_afspraak(Afspraken, {Starttijd, Eindtijd, Onderwerp}) ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	ets:insert(Afspraken, {{Starttijd, make_ref()}, Eindtijd, Onderwerp}),
	event_manager:post({Starttijd, activiteit, test_activiteit, [self(), Starttijd, Eindtijd, Onderwerp]}).

% add_afspraak_versie2 
% De gebruiker geeft bij het maken van een afspraak mee of hij een auto nodig heeft of niet
% Als hij er een nodig heeft wordt er automatisch een auto gereserveerd.
% De auto die gerseveerd wordt is altijd de bmw
% Bij deze versie zijn dubbele reservaties van de bmw mogelijk
add_afspraak_v2(Afspraken, {Starttijd, Eindtijd, Onderwerp, Auto_nodig}) ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	ets:insert(Afspraken, {{Starttijd, make_ref()}, Eindtijd, Onderwerp, Auto_nodig}),
	event_manager:post({Starttijd, activiteit, test_activiteit, [self(), Starttijd, Eindtijd, Onderwerp]}),
	case Auto_nodig of
		true -> 
			io:fwrite("Uw afspraak is gemaakt, er zal een auto gerserveerd worden... \n"),
			?MODULE:reserveer_auto({whereis(tesla), Starttijd, Eindtijd});
		false -> 
			io:fwrite("Uw afspraak is gemaakt, er is geen auto gereserveerd \n")
	end.

% Deze functie staat nog niet op punt
add_afspraak() ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	io:fwrite("Voer gegevens van je afspraak in"),
	Starttijd = io:get_line("Startuur > "),
	Eindtijd= io:get_line("Hoeveel uur duurt de activiteit? > "),
	Auto_nodig = io:get_line("Heeft u een auto nodig Y/N ? > "),

	io:fwrite("Je hebt een afspraak van "),
	io:fwrite(Starttijd),
	io:fwrite("uur geboekt, tot "),
	io:fwrite(Eindtijd).

reserveer_auto({Auto_pid, Starttijd, Eindtijd}) ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	Auto_pid ! {reserveer, {self(), Starttijd, Eindtijd}}.


loop(Afspraken) ->
    receive
		{add_afspraak, {Starttijd, Eindtijd, Onderwerp}} ->
			?MODULE:add_afspraak(Afspraken, {Starttijd, Eindtijd, Onderwerp}),
			?MODULE:loop(Afspraken);
		{add_afspraak, {Starttijd, Eindtijd, Onderwerp, Auto_nodig}} ->
			?MODULE:add_afspraak_v2(Afspraken, {Starttijd, Eindtijd, Onderwerp, Auto_nodig}),
			?MODULE:loop(Afspraken);
		{add_afspraak} ->
			?MODULE:add_afspraak(),
			?MODULE:loop(Afspraken);
		{reserveer_auto, {Auto_pid, Starttijd, Eindtijd}} ->
			?MODULE:reserveer_auto({Auto_pid, Starttijd, Eindtijd}),
			?MODULE:loop(Afspraken);
		stop -> ok
    end.