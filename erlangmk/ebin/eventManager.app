{application, eventManager, [
	{description, "Calendar application!"},
	{vsn, "0.1.1"},
	{modules, ['activiteit','auto','autoManager','ecalendar','eventManager','eventManager_app','eventManager_handler','index_dtl','persoon','testfile']},
	{registered, [eventManager]},
	{applications, [
		kernel,
		stdlib,
		cowboy,
		erlydtl
	]},
	{mod, {eventManager_app, []}},
	{env, []}
]}.
