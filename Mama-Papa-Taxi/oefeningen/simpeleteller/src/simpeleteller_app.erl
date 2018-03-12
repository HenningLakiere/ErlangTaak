-module(simpeleteller_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
	simpeleteller:start().

stop(_State) ->
	ok.
