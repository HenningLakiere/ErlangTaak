-module(testfile).
-export([start/0]).

start() ->
	ecalendar:new(),
	eventManager:start(),

	register(henning, persoon:new()),
	%register(mama, persoon:new()),

	whereis(henning) ! {maakAfspraak, {10000, 25000, werken, true}},
	%whereis(henning) ! {volgendeAfspraak},
	%whereis(henning) ! {cancelVolgendeAfspraak},
	
	observer:start().