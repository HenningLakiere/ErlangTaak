
% De auto manager houdt een tabel bij met daarin
% De Pid van alle auto's en het TableID van hun bijhorende reservaties

-module(auto_manager).
-export([start/0,
			init/0,
			loop/0,
			get_reservaties/3,
			check_periode/3,
			get_beschikbare_auto/2,
			add_auto/1]).

start() ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	Pid = spawn_link (?MODULE, init, []),
	register(auto_manager, Pid).

 init() ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
 	ets:new(auto_manage_table, [ordered_set, public, named_table]),
    loop().

add_auto({Pid, Tid}) ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	ets:insert_new(auto_manage_table, {Pid, Tid, element(2, process_info(Pid, registered_name))}).

% Check of er een auto beschikbaar is van Starttijd tot Eindtijd
% wanneer iemand voor die periode een auto wilt reserveren.
% Dit doen we door van elke auto de hele lijst met reservaties
get_beschikbare_auto(Begintijd, Eindtijd) ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	Auto_lijst = ets:match(auto_manage_table, '$1'),
	catch lists:foreach(fun(Auto)-> get_reservaties(Auto, Begintijd, Eindtijd) end, Auto_lijst).

get_reservaties(Auto, Begintijd, Eindtijd) ->
	%io:format("~p \n", [X]d),
	%io:format("~p \n", [element(2,lists:last(Auto))]),
	Reservatie_lijst = ets:match(element(2,lists:last(Auto)), '$1'),
	io:format("~p hier is de reservatielijst \n", [Reservatie_lijst]),
	%(Reservatie_lijst =:= [] andalso (io:format("Auto ~p is beschikbaar \n", [lists:last(Auto)]))), % als de lijst met reservaties nog leeg is
	%io:format("~p \n", [(Reservatie_lijst =:= [])]),
	case (Reservatie_lijst =:= []) of
		true -> 
			io:format("~p \n", [Auto]),
			Beschikbare_auto = element(1, lists:last(Auto)),
			io:format("We hebben een beschikbare auto gevonden \n"),
			io:format("~p \n", [Beschikbare_auto]),
			throw(auto_gevonden);
		false -> 
			% zoek verder
			A = lists:append(lists:merge(ets:match(element(2,lists:last(Auto)), {'$1','_','_'})), [infinity]),
			B = lists:append([0], lists:merge(ets:match(element(2,lists:last(Auto)), {'_','$1','_'}))),
			io:format("~p  dit is A\n", [A]),
			io:format("~p  dit is B\n", [B]),
			catch lists:foreach(fun(Reservatie) -> check_periode(lists:last(Reservatie), Begintijd, Eindtijd) end, Reservatie_lijst) % lists:last(Reservatie) om de [] weg te doen
	end.

check_periode(Reservatie, Begintijd, Eindtijd) ->
	% io:format("~p sqfqsdf \n", [Reservatie]),
	Reservatie_starttijd = element(1, Reservatie),
	Reservatie_eindtijd = element(2, Reservatie).

loop() ->
    receive
		{add_auto, {Pid, Tid}} ->
			?MODULE:add_auto({Pid, Tid}),
			?MODULE:loop();
		stop -> ok
    end.


% verkrijg een lijst van elle tuples in een ets tabel mbv:
% ets:match(tabel, '$1').
%7> ets:match(24597, {'_',7000,'_'}). 
%[[]]
%8> ets:match(24597, {'$1',7000,'_'}).
%[[{<0.39.0>,#Ref<0.0.2.52>}]]
%9> ets:match(24597, {'$1',7000,'$1'}).
%[]
%10> ets:match(24597, {'$1',7000,'$2'}).
%[[{<0.39.0>,#Ref<0.0.2.52>},8000]]
