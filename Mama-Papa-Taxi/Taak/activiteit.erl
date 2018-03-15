-module(activiteit).
-export([testActiviteit/5]).

%afspraak afprinten die gemaakt wordt
testActiviteit(Pid, B, E, D, A) ->
	Name = getProcesName(Pid),
	%auto nodig of niet
	Auto = if
		A ->
			een;
		true ->
			geen
	end,
	io:format("~p moet nu ~p van ~p tot ~p en heeft hiervoor ~p auto nodig~n", [Name, D, B, E, Auto]).

getProcesName(Pid) ->
	{_, Name} = erlang:process_info(Pid, registered_name),
	Name.
