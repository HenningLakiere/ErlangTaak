-module(input).
-export([start/0, get/0, loop/1]).

start() ->
	A = ets:new(a, [ordered_set]),
	spawn(?MODULE, loop, [A]).

get() ->
	A = io:fread("Keuze wagen: ","~a"),
	A.

loop(A) ->
	receive
		{get} ->
			?MODULE:get(),
			?MODULE:loop(A);
		_ ->
			?MODULE:loop(A)
	end.
