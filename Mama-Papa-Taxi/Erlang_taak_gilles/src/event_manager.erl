%% @doc Simulation/emulation event manager 
%%      registered process : event_manager
%%
%% @author Paul Valckenaers (K.U.Leuven, Belgium), 
%% @author Leo Rutten       (K.U.Leuven, Belgium)  
%
% @version 17/11/2014

-module(event_manager). 

%% events are tuples matching {Time, M, F, Args} where 
%% eventmgr will call "spawn(M, F, Args)" when Time has been reached

%% -import(ecalendar, [init/0, insert/1, first/0, 
%%                         nextEventTime/0, removefirst/0]). 
%% event_manager uses fully qualified function calls - no import needed

%% user functions 
-export([start/0, start_new/0, post/1, postincr/1, gettime/0, stop/0]). 

%% for internal use (spawn) only 
-export([loop/1]).

start() ->
   (whereis(event_manager) =:= undefined) andalso 
                              (?MODULE:start_new()). 

start_new() ->
   io:format("event_manager:start_new()~n"),
   ecalendar:init(), 
   (whereis(event_manager) =:= undefined) orelse 
                     unregister(event_manager), 
   Pid = spawn_link (?MODULE, loop, [now()]),
   register(event_manager, Pid),
   {ok, Pid}. 

stop() -> event_manager ! stop.
   
post({Time, M, F, Args}) -> 
   event_manager ! {post__event, {Time, M, F, Args}}. 
                  
postincr({Delay, M, F, Args}) -> 
   event_manager ! {post__incr_event, {Delay, M, F, Args}}.  
   
gettime() -> 
   R = make_ref(),
   event_manager ! {get_time, self(), R},
   receive
      {R, Time} -> {ok, Time}
   end.
   
loop(TimeAtStart) -> 
      %% TimeAtStart    now()-value when initiating
      %%              real-time simulation run
%% Compute current time of the real time simulation in microseconds
   Time = timer:now_diff(now(), TimeAtStart),  
%% Next, manage simulation calendar and progress of the simulation time base.
   NET = ecalendar:nextEventTime(),  %% at the start, NET equals infinity.
   if 
   %% Case 1: Simulation time has caught up with the earliest "post".
   %%  To Do: Notify the "posting process" and remove event from calendar.
      NET =< Time -> 
         { _ , M, F, Args} = ecalendar:first(), 
         spawn(M, F, Args), 
         ecalendar:removefirst(),
         ?MODULE:loop(TimeAtStart);
   %% Case 2: wait for WT milliseconds unless a message arrives
      true -> 
         WT = 
         if  %% compute WT in milliseconds
            NET =:= infinity -> 
               infinity;
            true -> 
               ((NET - Time) div 1000) + 1
         end,
         receive 
            {post__incr_event, {Delay, M, F, Args}} -> 
               PostingTime = timer:now_diff(now(), TimeAtStart) +(Delay * 1000),
               ecalendar:insert({PostingTime, M, F, Args}),
               ?MODULE:loop (TimeAtStart);
            {post__event, {T, M, F, Args}} -> 
               ecalendar:insert({T * 1000, M, F, Args}),
               ?MODULE:loop (TimeAtStart);             
            {get_time, ResponsePid2, UniqueRef3} ->
               CurrentTime = timer:now_diff(now(), TimeAtStart) div 1000,
               ResponsePid2 ! {UniqueRef3, CurrentTime},
               ?MODULE:loop(TimeAtStart);                           
            stop -> void    %% to stop the testing run         
                              
         after WT ->  %% Future work: add a speed-up/slow-down factor 
            ?MODULE:loop(TimeAtStart)
            %% timeout will be at least (NET - Time), 
            %% likely to be 1-25 milliseconds longer. 
            %% I.e., notification happens within the blink of an eye. 
      end
   end. 
   
