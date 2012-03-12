
component 
	output="true"
	hint="I define the application settings and event handlers."
	{


	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 20, 0 );
	this.sessionManagement = false;
	
	// Set up the WebSocket channels. For this demo, I'm only 
	// going to use one channel listener for all my channels. The
	// WSApplication component simply acts as a proxy and points
	// ass WebSocket requests back to the Application.cfc, as if 
	// they were standard requests. Using four new methods:
	//
	// - onWSRequestStart() :: Boolean
	// - onWSRequest() :: Any (message)
	// - onWSResponseStart() :: Boolean
	// - onWSResponse() :: Any (message)
	//
	// NOTE: These are *NOT* core WebSocket methods. This is simply
	// the approach I've used to learn about ColdFusion 10 WebSockets.
	this.wsChannels = [
		{
			name: "chat",
			cfcListener: "WSApplication"
		}
	];
	
	
	// I authenticate the given WebSocket user.... 
	// NOT SURE WHAT THIS DOES JUST YET.
	function onWSAuthenticate( username, password, connection ){
		
		// Authenticate all users.
		connection.authenticated = true;
		connection.role = "anyUser";
		return( true );
		
	}
	
	
	// I initialize the incoming WebSocket request. The possible
	// types are [ subscribe | unsubscribe | publish ]. If I return
	// False, the request will not processed and the given request
	// (subscribe | publish) will be refused.
	function onWSRequestStart( type, channel, user ){
		
		// Check to see if the current request is for a new 
		// subscription to the Chat. If so, we'll want to announce
		// the new user to the rest of the chat room.
		if (
			(type == "subscribe") &&
			(channel == "chat.message")
			){
			
			// Publish a new subscription notice to all users.
			wsPublish( "chat.userlist.subscribe", user );
			
		} else if (
			(type == "unsubscribe") &&
			(channel == "chat.message")
			){
			
			// Publish a new unsubscription notice to all users.
			wsPublish( "chat.userlist.unsubscribe", user );
			
		}
		
		// Return true so the request will be processed.
		return( true );
		
	}
	
	
	// I execute the incmoing WebSocket request (to publish). A 
	// message must be returned (which will initialize the response)
	// that gets published to all relevant subscribers.
	function onWSRequest( channel, user, message ){
		
		// Check to see if the message ends in "!". If so, we'll 
		// upper-case the entire value. 
		if (
			(channel == "chat.message") &&
			reFind( "!$", message.message )
			){
			
			// Upper-case the EXCITED message!
			message.message = ucase( message.message );
			
		}
		
		// Return the message to publish to all users.
		return( message );
		
	}
	
	
	// I initialize the outgoing WebSocket response from the given
	// publisher to the given subscriber. This is called for every
	// subscriber on the given channel. Return True to allow the
	// message to be published to the given client. Return False to
	// prevent the message from being publisehd to the given client.
	function onWSResponseStart( channel, subscriber, publisher, message ){
		
		// We don't want to post BACK to the same user. So, only let
		// response (publication) through if the publisher and the 
		// subscriber are NOT the same person.
		if (
			(channel == "chat.message") &&
			(publisher.clientID == subscriber.clientID)
			){
			
			// Prevent message echo.
			return( false );
			
		}
		
		// Return true so the message will be published. 
		return( true );
		
	}
	
	
	// I execute the outgoing WebSocket response. A message must be
	// returned (which is what will be sent to the given user). This 
	// provides a chance to format a message for an individual user.
	function onWSResponse( channel, user, message ){
		
		// Return the message to publish to THIS user.
		return( message );
		
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





















