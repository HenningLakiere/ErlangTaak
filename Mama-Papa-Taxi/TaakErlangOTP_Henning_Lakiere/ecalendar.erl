%% @doc Simulation/emulation time base and calendar using ets
%%    Event calendar is a named ets table : ecalendar
%%
%% @author Paul Valckenaers    (KU Leuven, Belgium), 
%% @author Leo Rutten          (KU Leuven, Belgium) 
%
% @version 21/ 2/2014

-module(ecalendar).

-export([init/0, insert/1, first/0, nextEventTime/0, removefirst/0]). 

init() ->
   ets:info(ecalendar) =:= undefined orelse ets:delete(ecalendar), 
   ets:new(ecalendar, [ordered_set, public, named_table]), 
   insert({infinity, eventmanager, stop, []}),
   {ok, ecalendar}.

insert({ infinity, M, F, Args}) -> 
   ets:insert_new(ecalendar, {{infinity, make_ref()}, M, F, Args});
   
insert({Time, M, F, Args}) 
   when 
      is_integer(Time) 
   and 
      is_atom(M) 
   and 
      is_atom(F)
   and
      is_list(Args)
   ->
      ets:insert_new(ecalendar, {{Time, make_ref()}, M, F, Args}).

first() -> 
   Key = ets:first(ecalendar),
   [{{Time, _ }, M, F, Args}] = ets:lookup(ecalendar, Key),
   {Time, M, F, Args}.

nextEventTime() -> 
   {Time, _ } = ets:first(ecalendar), 
   Time. 
   
removefirst() ->
   Key = ets:first(ecalendar),
   ets:delete(ecalendar, Key).
   
% is_atom/1           is_binary/1        
% is_bitstring/1      is_boolean/1        is_builtin/3       
% is_float/1          is_function/1       is_function/2      
% is_integer/1        is_list/1           is_number/1        
% is_pid/1            is_port/1           is_record/2        
% is_record/3         is_reference/1      is_tuple/1  
