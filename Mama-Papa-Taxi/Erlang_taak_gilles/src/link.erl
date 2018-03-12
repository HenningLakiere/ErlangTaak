%
% @version $Date: 2014-02-21 16:04:36 +0100 (Fri, 21 Feb 2014) $

-module(link).

-export([create/0, get_from/1, get_to/1, set_from/2, set_to/2]).
-export([loop/2]).

create() ->
   spawn(?MODULE, loop, [unconnected, unconnected]).

get_from(LinkPid) ->
   Ref = make_ref(),
   LinkPid ! {get_from, self(), Ref},
   receive
      {ResPid, Ref} -> {ok, ResPid}
   end.

get_to(LinkPid) ->
   Ref = make_ref(),
   LinkPid ! {get_to, self(), Ref},
   receive
      {ResPid, Ref} -> {ok, ResPid}
   end.

set_from(LinkPid, ResPid) -> LinkPid ! {set_from, ResPid}, ok.

set_to(LinkPid, ResPid) -> LinkPid ! {set_to, ResPid}, ok.

loop(FromRes, ToRes) ->
   receive
      {set_from, From} ->
         ?MODULE:loop(From, ToRes);
      {set_to, To} ->
         ?MODULE:loop(FromRes, To);
      {get_from, Pid, Ref} ->
         Pid ! {FromRes, Ref},
         ?MODULE:loop(FromRes, ToRes);
      {get_to, Pid, Ref} ->
         Pid ! {ToRes, Ref},
         ?MODULE:loop(FromRes, ToRes)
   end.
