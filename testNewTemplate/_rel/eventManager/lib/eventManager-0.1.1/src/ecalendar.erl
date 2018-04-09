-module(ecalendar).
-export([new/0, insert/1, nextEventTime/0, getFirst/0, deleteFirst/0]).

new() ->
	ets:new(ecalendar, [ordered_set, public, named_table]),
  insert({infinity, eventManager, stop, []}),
  {ok, ecalendar}.

%M = manager
%F = function
%Args = arguments

insert({infinity, M, F, A}) ->
	ets:insert(ecalendar, {{infinity, make_ref()}, M, F, A});

insert({Time, M, F, A})
	when 
      is_integer(Time) 
   and 
      is_atom(M) 
   and 
      is_atom(F)
   and
      is_list(A)
   ->
   	  ets:insert(ecalendar, {{Time, make_ref()}, M, F, A}).

nextEventTime() ->
  {Time, _} = ets:first(ecalendar),
  Time.

deleteFirst() ->
  Key = ets:first(ecalendar),
  ets:delete(ecalendar, Key).

getFirst() ->
	Key = ets:first(ecalendar),
	[{{Time, _ }, M, F, Args}] = ets:lookup(ecalendar, Key),
  {Time, M, F, Args}.





