
component 
	output="false"
	hint="I define the application settings and event handlers."
	{


	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 5, 0 );
	
	// Turn on session management.
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan( 0, 0, 5, 0 );
	
	// Set up the WebSocket channels.
	this.wsChannels = [
		{
			name: "demo",
			cfcListener: "WSApplication"
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
	
	
	// I initialize the session.
	function onSessionStart(){
		
		// Set up the default session values.
		session.id = 0;
		session.name = "";
		
		// Return out.
		return;
		
	}
	
	
	// ------------------------------------------------------ //
	// ------------------------------------------------------ //
	// -- WebSocket Event Handlers -------------------------- //
	// ------------------------------------------------------ //
	// ------------------------------------------------------ //
	
	
	// I initialize the WebSocket session. This gives us an 
	// opportunity to associate a WebSocket connection with a given
	// user in the system.
	function onWSSessionStart( user ){
		
		// Param the UserID being passed through in the FORM scope 
		// (which is coming through in the custom WebSocket headers).
		param name="form.userID" type="numeric" default="0";
		
		// Store the User ID in the persistent connection info of
		// the WebSocket user.
		user.userID = form.userID;
		
		// Return out.
		return;
		
	}
	
	
	// I initialize the outgoing WebSocket response. This will get 
	// invoked for every subscriber that has subscribed to the given
	// channel. This means we can determine the pass-through for each
	// subscirber (based on return of TRUE | FALSE).
	function onWSResponseStart( channel, subscriber, publisher, message ){
		
		// Check to see if the given subscriber is the intended 
		// target for the given message. For this, we'll use the
		// targetUserID property in the message.
		if (
			isNull( message.targetUserID ) ||
			isNull( subscriber.userID ) ||
			(message.targetUserID != subscriber.userID)
			){
			
			// The subscriber is NOT the intended target.
			return( false );
			
		}
		
		// If we made it this far, the subscriber was the intended
		// target of the message.
		return( true );
		
	}
	
	
	// I execute the WebSocket response.
	function onWSResponse( channel, subscriber, message ){
		
		// Right now, the message contains superfluous data regarding
		// the target user. The subscriber doesn't actually need that
		// message; so, let's unwrap the actual payload.
		return( message.text );
		
	}
	
	
	// ------------------------------------------------------ //
	// ------------------------------------------------------ //


	// I log the arguments to the text file for debugging.
	function logData( data ){
		
		// Create a log file path for debugging.
		var logFilePath = (
			getDirectoryFromPath( getCurrentTemplatePath() ) & 
			"log.txt"
		);
		
		// Dump to TXT file.
		writeDump( var=data, output=logFilePath );
		
	}
	
	
}





















