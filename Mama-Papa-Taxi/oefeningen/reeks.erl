-module(reeks).

-export([start/1]).

start(N) ->
	io:format("Start!~n"),
	C = self(),

	[spawn(
	   fun() ->
		C ! 1/I
	   end
	) || I <- lists:seq(1,N)],

	L = [receive T -> T end || _I <- lists:seq(1,N)],
	lists:foldl(fun(X, Som) -> X+Som end, 0, L).

