-module(eventManager_app).
-behaviour(application).
-export([start/2]).
-export([stop/1]).
start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
					  %% {URIHost, list({URIPath, Handler, Opts})}
					  {'_', [{'_', eventManager_handler, []}]}
	]),
	%% Name, NbAcceptors, TransOpts, ProtoOpts
	cowboy:start_http(my_http_listener, 100,
			  [{port, 8080}],
			  [{env, [{dispatch, Dispatch}]}]
			 ).
	%ecalendar:new(),
	%eventManager:start().
	%register(autoManager, autoManager:start()).
	%register(henning, persoon:new()).
	%register(tesla, auto:new()).
	%whereis(henning) ! {maakAfspraak, {100000, 150000, werken, true}}.
	%testfile:start().

stop(_State) ->
	ok.
