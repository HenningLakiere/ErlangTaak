% Elke functie die ik zelf heb gemaakt roept in eerste 
% instatie de functie debug_log_survivor:log_function() op.
% Wanneer er dan een error optreedt kan ik in de ets tabel 'debug_log' gaan kijken
% welke functie voor het laatst uitgevoerd werd.
% De ets tabel 'debug_log' is gebaseerdt op het 'survivor' voorbeeld uit de les zodat er
% bij een crash geen data verloren gaat.

-module(debug_log_survivor).

-export([start/0, loop/0, log_function/1]).

start() -> 
	spawn(debug_log_survivor, loop, []).

%voeg een uitgevoegde functie toe aan het logboek
log_function(Process_info) -> 
	%De functie ?FUNCTION bestaat niet, maar dit biedt een oplossing
	%A = aantal argumenten
	%{current_function, {M, F, A}} = process_info(self(), current_function).
	
	ets:insert(debug_log, {ets:info(debug_log, size), element(2, Process_info)}).

loop() 
	-> ets:new(debug_log, [public,ordered_set, named_table]),
	receive
		stop -> ok
	end.