
component 
	output="false"
	hint="I define the application settings and event handlers."
	{


	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 5, 0 );
	
	// Turn off session management. In this case, we'll just rely  
	// completely on the values being passed through the WebSocket
	// custom headers.
	this.sessionManagement = false;
	
	// Set up the WebSocket channels.
	// 
	// NOTE: We are NOT defining a Channel Listener - using the 
	// native WebSocket filtering and selector functionality is 
	// mutually exclusive with the Channel Listener (ie. it's doing
	// exactly what YOU would have had to do in your own Channel 
	// Lister component).
	this.wsChannels = [
		{
			name: "demo"
		}
	];
	
	
	// I initialize the application.
	function onApplicationStart(){
		
		// Define some users with different IDs. For this demo, we're
		// gonna look at Pushing messages to specific clients.
		application.users = [
			{
				id: 1,
				name: "Joanna"
			},
			{
				id: 2,
				name: "Sarah"
			},
			{
				id: 3,
				name: "Tricia"
			}
		];
		
		// Return true to the application can load.
		return( true );
		
	}

	
}





















