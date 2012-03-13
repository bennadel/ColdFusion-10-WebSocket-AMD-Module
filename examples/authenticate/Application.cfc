
component 
	output="false"
	hint="I define the application settings and event handlers."
	{


	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 5, 0 );
	this.sessionManagement = false;
	
	// Set up the WebSocket channels.
	this.wsChannels = [
		{
			name: "demo",
			cfcListener: "WSApplication"
		}
	];
	
	
	// I initialize the application.
	function onApplicationStart(){
		
		// Set up our cache of user accounts. Obviously, this would
		// normally be in a database; but for this demo, we'll just
		// use a simple in-memory store.
		application.accounts = [
			{
				id: 1,
				username: "ben",
				password: hash( "benpw" )  
			},
			{
				id: 2,
				username: "sarah",
				password: hash( "sarahpw" )
			},
			{
				id: 3,
				username: "tricia",
				password: hash( "triciapw" )
			}
		];
		
		// Return true so the request can process.
		return( true );
		
	}
	
	
	// I handle WebSocket authentication requests. Since WebSocket
	// requests do not send any Cookies over the wire, we have to 
	// handle authorization and state-management with a separate
	// set of features. 
	function onWSAuthenticate( username, password, connection ){
		
		// Check to see if this credentials are correct.
		var index = arrayFind(
			application.accounts,
			function( account ){
				
				// Return true if the username/password match.
				return(
					(account.username == username) &&
					(account.password == hash( password ))
				);
				
			}
		);
		
		// Check to see if we found a matching record. 
		if (!index){
			
			// NO matching record found! The provided credentials,
			// were not valid. Simply return false in order to 
			// signify the failure (and prevent the "authenticate")
			// event on the client.
			return( false );
			
		}
		
		// Flag the client as authenticated (this is for 
		// programmatic use - this does not seem to affect the way
		// the code implicitly reacts to subsequent requests).
		connection.authenticated = true;
		
		// Store the user's record ID with the connection information.
		// This information will be available across all channels for
		// all requests made by this client.
		connection.userID = application.accounts[ index ].id; 
		
		// Return true to signify a successful authentication. This 
		// will trigger the "authenticate" event on the client.
		return( true );
		
	}
	
	
	// I initialize the incoming WebSocket request. In this case
	// we're just gonna run through a number of scopes and data
	// points to see if they exist during a WebSocket request.
	function onWSRequestStart( type, channel, user ){
		
		// If this is a call to publish, let's check to see if the
		// user has been authenticated. 
		if (type == "publish"){
			
			// Check for the user ID
			if (
				isNull( user.userID ) ||
				!user.userID
				){
			
				// This user is NOT authenticated.
				logData( "Publish denied - user not authenticated." );
			
				// Return false so the publish request is cancelled.
				return( false );
				
			}
			
			// If we made it this far, the user is authenticated!
			// Log the user ID.
			logData( "Publish accepted for User ID #user.userID#" );
			
		}
		
		// If we made it this far, return true so that the request
		// may be fully processed.
		return( true );
		
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





















