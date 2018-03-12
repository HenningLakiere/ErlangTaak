-module(testfile).

-export([start/0]).


start() ->
	debug_log_survivor:start(),
	event_manager:start(),

	debug_log_survivor:log_function(process_info(self(), current_function)),

	% Testing
	event_manager:post({1000, activiteit, test_activiteit, []}),

	% RESOURCES MAKEN
	% Personen
	% door te registreren komt er in de de Table Viewer van de observer een Owner Name$
	% te staan, dit helt bij debuggen.

	register(mario, persoon:start()),
	register(henning, persoon:start()),

	% Auto's
	register(tesla, auto:start()),
	register(ford, auto:start()),


	% henning en Robin zetten afspraken in hun agenda
	% in dit geval tijdstippen waarop ze naar de les moeten
	whereis(mario) ! {add_afspraak, {2000,3000,"Erlang les"}},
	whereis(mario) ! {add_afspraak, {3000,4000,"DSP les"}},
	%whereis(robin) ! {add_afspraak, {3500,4000,"DSP les", 0}},

	whereis(henning) ! {add_afspraak, {4000, 5000, "Haskell les"}},
	whereis(henning) ! {add_afspraak, {5000, 6000, "Bedrijfsmanagement les"}},

	% henning reserveert de bwm voor een bepaalde periode
	whereis(tesla) ! {reserveer, {whereis(henning), 7000, 8000}},
	whereis(henning) ! {reserveer_auto, {whereis(tesla), 9000, 10000}},

	% add_afspraak waarbij automatisch auto wordt gereserveerd wanneer
	% het laatste arguement true is 
	whereis(henning) ! {add_afspraak,{10000,11000, "Wandeling maken met de hond", false}}, 
	whereis(henning) ! {add_afspraak,{11000,12000, "Naar de zee gaan", true}}, 

	observer:start().

