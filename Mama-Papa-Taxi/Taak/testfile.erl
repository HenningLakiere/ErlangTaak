-module(testfile).
-export([start/0]).

start() ->
	ecalendar:new(),
	eventManager:start(),

	register(autoManager, autoManager:start()),

	register(henning, persoon:new()),
	register(mama, persoon:new()),

	register(toyota, auto:new()),
	register(tesla, auto:new()),

	whereis(tesla) ! {maakReservering, {5000, 8000, whereis(henning), wassen}},

	%whereis(autoManager) ! {getReservaties, tesla},

	%whereis(henning) ! {maakAfspraak, {5000, 8000, werken, true}},
	%whereis(henning) ! {maakAfspraak, {9000, 10000, werken, true}},
	%whereis(mama) ! {maakAfspraak, {2000, 5000, werken, true}},
	%whereis(mama) ! {maakAfspraak, {6000, 8000, werken, false}},
	%whereis(henning) ! {maakAfspraak, {2000, 4000, werken, true}},

	%whereis(henning) ! {volgendeAfspraak},
	%whereis(henning) ! {cancelVolgendeAfspraak},


	
	observer:start().