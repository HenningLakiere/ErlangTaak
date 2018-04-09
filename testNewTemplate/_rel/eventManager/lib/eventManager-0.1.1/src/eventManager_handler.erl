-module(eventManager_handler).
-behaviour(cowboy_http_handler).

-export([init/3]).
-export([handle/2]).

-export([terminate/3]).

init(_Type, Req, _Opts) ->
	{ok, Req, undefined_state}.

handle(Req, State) ->
	Event = ecalendar:getFirst(),
	{ok, Body} = index_dtl:render([{pid, Event}]),
	Headers = [{<<"content-type">>, <<"text/html">>}],	
	{ok, Req2} = cowboy_req:reply(200, Headers, Body, Req),
	{ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
	ok.
