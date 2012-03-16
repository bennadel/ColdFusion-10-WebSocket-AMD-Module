
component 
	output="false"
	hint="I define the application settings and event handlers."
	{


	// Define the application settings.
	this.name = hash( getCurrentTemplatePath() );
	this.applicationTimeout = createTimeSpan( 0, 0, 1, 0 );
	
	// Enable session management.
	this.sessionManagement = true;
	this.sessionTimeout = createTimeSpan( 0, 0, 1, 0 );
	
	// Set up the WebSocket channels.
	this.wsChannels = [
		{
			name: "demo",
			cfcListener: "WSApplication"
		}
	];
	
	
	// I initialize the application.
	function onApplicationStart(){
		
		// This is a collection of active sessions in the application
		// as determined by a hash of the session cookies.
		application.sessions = {};
		
		// Return true the request can be processed.
		return( true );
		
	}
	
	
	// I initialize the session.
	function onSessionStart(){
		
		// Add this session reference to the active, cached sessions 
		// so we can easily keep track of the session across 
		// different request mediums. In this case, we're hashing the
		// look-up key for the session so that we can pass it publicly
		// without concern.
		application.sessions[ hash( session.sessionID ) ] = session;
		
		// Set up the initial session values.
		session.isLoggedIn = false;
		session.name = "";
		
		// Return out.
		return;
		
	}
	
	
	// I execute the request.
	function onRequest(){
		
		// Check to see if the use is "logged-in". If not, we'll 
		// force them into the login form.
		if (session.isLoggedIn){
			
			// Show standard form.
			include "index.cfm";
			
		} else {
			
			// Force the login.
			include "login.cfm";
			
		} 
		
		// Return out.
		return;
		
	}
	
	
	// I teardown the session.
	function onSessionEnd( sessionScope, applicationScope ){
		
		// Remove the active session from the application cache.
		structDelete( 
			applicationScope.sessions,
			hash( sessionScope.sessionID ) 
		);
		
		// Return out.
		return;
		
	}
	
	
	// ------------------------------------------------------ //
	// ------------------------------------------------------ //
	// -- WebSocket Event Handlers -------------------------- //
	// ------------------------------------------------------ //
	// ------------------------------------------------------ //
	
	
	// I initialize the WebSocket session.
	function onWSSessionStart( user ){
		
		// Param the form values for CFID and CFTOKEN. NOTE: These
		// are getting passed from the client as custom header and
		// be injected into the FORM scope in WSApplication.cfc.
		param name="form.cfid" type="string" default="";
		param name="form.cftoken" type="string" default="";
		
		// Create our session ID key for active sessions using the
		// application name and the session tokens.
		var sessionID = "#this.name#_#form.cfid#_#form.cftoken#";
		
		// Hash the sessionID - this is how we are keying our cached
		// session references.
		var sessionHash = hash( sessionID );
		
		// Check to see if we have an active standard session 
		// associated with these session tokens.
		if (structKeyExists( application.sessions, sessionHash )){
			
			// Bind the STANDARD session to the WEBSOCKET session!!!
			user.session = application.sessions[ sessionHash ]; 
			
		}
		
		// Return out.
		return;
		
	}
	
	
	// I initialize the incoming WebSocket request. In this case
	// we're just gonna run through a number of scopes and data
	// points to see if they exist during a WebSocket request.
	function onWSRequestStart( type, channel, user ){

		// Check to see if this is a subscribe request. If so, let's
		// we have to make sure that the user is logged-in.
		if (
					!user.session.isLoggedIn 
				&&
					(
						(type == "subscribe") ||
						(type == "publish")
					)
			){
			
			// User must log-in first.
			return( false );
			
		}

		// If we made it this far, return true so that the request
		// may be fully processed.
		return( true );
		
	}
	
	
	// I execute the WebSocket request.
	function onWSRequest( channel, publisher, message ){
		
		// Check to see if this is a server-initiated response. If 
		// so, then the publisher won't have a valid clientID or a
		// session.
		if (publisher.clientID){
			
			// Prepend the FROM user's name.
			return( "[FROM: #publisher.session.name#] #message#" );
			
		// This is a server-initiated event.
		} else {
			
			// Prepend the Server's name.
			return( "[FROM: Server] #message#" );
			
		}
		
	}
	
	
	// I execute the response to the WebSocket subscriber.
	function onWSResponse( channel, subscriber, message ){
		
		// Prepend the TO user's name.
		return( "[TO: #subscriber.session.name#] #message#" );
		
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





















