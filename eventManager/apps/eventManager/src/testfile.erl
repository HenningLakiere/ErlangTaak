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
	register(audi, auto:new()),
	register(suzuki, auto:new()),
	%register(volkswagen, auto:new()),
	%register(zonda, auto:new()),

	%observer:start(),
	%whereis(autoManager) ! {getReservaties, tesla},

	whereis(henning) ! {maakAfspraak, {1000, 1500, werken, true}},
	whereis(henning) ! {maakAfspraak, {2000, 2500, werken, true}},
	whereis(mama) ! {maakAfspraak, {2100, 10000, werken, true}},
	whereis(mama) ! {maakAfspraak, {6100, 8000, werken, true}},
	whereis(henning) ! {maakAfspraak, {3000, 3500, werken, true}},
	whereis(henning) ! {maakAfspraak, {4000, 4500, werken, false}},
	whereis(henning) ! {maakAfspraak, {5000, 5500, werken, true}},
	whereis(henning) ! {maakAfspraak, {6000, 6500, werken, false}},
	whereis(henning) ! {maakAfspraak, {7000, 7500, werken, true}},
	whereis(henning) ! {maakAfspraak, {7600, 8500, werken, true}}.

	%whereis(autoManager) ! {getBeschikbareWagens, {1, 2}},


	%whereis(henning) ! {volgendeAfspraak},
	%whereis(henning) ! {cancelVolgendeAfspraak},


	
	
