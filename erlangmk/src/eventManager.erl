-module(eventManager).
-export([start/0, init/0, post/1, deletePost/1, loop/1, stop/0]).

start() ->
	Pid = spawn(?MODULE, init, []),
	register(eventManager, Pid),
	{ok, Pid}.

init() ->
	loop(erlang:system_time(millisecond)).

post({Time, M, F, Args}) -> 
	eventManager ! {post__event, {Time, M, F, Args}}.

deletePost({Time, M, F, Args}) ->
	eventManager ! {deletePost, {Time, M, F, Args}}.

loop(StartTime) ->
	Time = erlang:system_time(millisecond) - StartTime,
	NextEventTime = ecalendar:nextEventTime(),
	X = if
		NextEventTime =:= infinity ->
			infinity;
		true ->
			NextEventTime - Time
	end,
	receive
		{post__event, {T, M, F, Args}} -> 
            	ecalendar:insert({T, M, F, Args}),
            	?MODULE:loop (StartTime);
        {deletePost, {T, M, F, Args}} ->
        		ecalendar:insert({T, M, F, Args}),
           		?MODULE:loop (StartTime);
		{stop} ->
			ok;
		_ ->
			loop(StartTime)
	after
		X ->
			{_ , M, F, Args} = ecalendar:getFirst(),
         	spawn(M, F, Args), 
			ecalendar:deleteFirst(),
			loop(StartTime)
	end.

stop() ->
	eventManager ! {stop}.
