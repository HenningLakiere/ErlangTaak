-module(testfile).
-export([start/0]).

start() ->
	ecalendar:new(),
	eventManager:start(),

	register(autoManager, autoManager:start()),

	register(henning, persoon:new()),
	register(mama, persoon:new()),
	register(papa, persoon:new()),
	register(joke, persoon:new()),
	register(anna, persoon:new()),
	
	register(toyota, auto:new()),
	register(tesla, auto:new()),
	register(audi, auto:new()).
