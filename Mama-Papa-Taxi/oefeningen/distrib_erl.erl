-module(distrib_erl).
-export([start_ontvanger/0,start_zender/2,loopo/0,loopz/0]).

start_ontvanger() ->
	Pid = spawn(distrib_erl, loopo, []),
	register(ontvanger, Pid),
	Pid.

loopo() ->
	receive
		{bericht, I, Afzender}  ->
			io:format("bericht ~p ontvangen van ~p~n", [I, Afzender]),
			Afzender ! {antwoord, I, self()},
			loopo();
		X ->
			io:format("onbekend bericht ~p~n",[X]),
			loopo()
	end.

start_zender(N, Node) ->
	Pid = spawn(distrib_erl, loopz, []),
	[ {ontvanger,Node} ! {bericht, I, Pid}|| I <- lists:seq(1,N)].

loopz() ->
	receive
		{antwoord, I, Afzender}  ->
			io:format("antwoord ~p ontvangen van ~p~n", [I, Afzender]),
			loopz();
		X ->
			io:format("onbekend antwoord ~p~n",[X]),
			loopz()
	end.


