-module(eventmanager_app).
-behavior(application).
 
-export([start/2]).
-export([stop/1]).
 
start(_Type, _Args) ->
    event_manager:start_new().
 
stop(_State) ->
    ok.


