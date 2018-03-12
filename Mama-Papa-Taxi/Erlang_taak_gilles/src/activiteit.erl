-module(activiteit).

-export([test_activiteit/0, 
			test_activiteit/1, 
			test_activiteit/4]).


test_activiteit() ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	io:fwrite("\n"),
	io:fwrite("Testactiviet wordt nu uitgevoerd: \n").

% print het onderwerp van de activitet in de terminal wanner de activieit wordt uitgevoerd
test_activiteit(Onderwerp) ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	io:fwrite("\n"),
	io:fwrite("Testactiviet wordt nu uitgevoerd: \n"),
	io:fwrite(Onderwerp),
	io:fwrite("\n").

% print Pid van de persoon van wie de activiteit is en het onderwerp van de activiteit
test_activiteit(Persoon_pid, Starttijd, Eindtijd, Onderwerp) ->
	debug_log_survivor:log_function(process_info(self(), current_function)),
	io:fwrite("\n"),
	io:fwrite("Testactiviet wordt nu uitgevoerd: \n"),
	io:fwrite("~p: ~p - ~p --- ~p \n", [element(2, process_info(Persoon_pid, registered_name)), Starttijd, Eindtijd, Onderwerp]).

