
component 
	extends="CFIDE.websocket.ChannelListener"
	output="true"
	hint="I define the application settings and event handlers."
	{
	
	
	// Store an instance of the Application.cfc that we'll use to 
	// process these WebSocket requests. This component (WSApplication),
	// gets cached. As such, we'll have to re-instantiate the target
	// Application component at key points during the lifecycle. 
	this.application = {};
		
	
	// I teardown a subscription, removing any necessary settings
	// for the given subscriber.
	function afterUnsubscribe( requestInfo ){
		
		// Re-instantiate the target application.
		this.application = new Application();
	
		// Check to see if the application will process this event.
		if (!structKeyExists( this.application, "onWSRequestStart" )){
			
			// Nothing to do.
			return;
			
		}
		
		// Pass this off to the application for processing. Since
		// this has no bearing on the request, we don't have to
		// capture the response. This is purely a utilitarian call.
		this.application.onWSRequestStart(
			"unsubscribe",
			requestInfo.channelName,
			this.normalizeConnection( requestInfo.connectionInfo )
		);
	
		// Return out.
		return;
			
	}
	
	
	// I determine if the given user can publish the given information.
	function allowPublish( requestInfo ){

		// Re-instantiate the target application.
		this.application = new Application();
		
		// Check to see if the application will process this event.
		if (!structKeyExists( this.application, "onWSRequestStart" )){
			
			// Nothing to do.
			return( true );
			
		}
		
		// Pass this off to the application for processing.
		var result = this.application.onWSRequestStart(
			"publish",
			requestInfo.channelName,
			this.normalizeConnection( requestInfo.connectionInfo )
		);
		
		// Check to see if the request should be processed.
		if (
			isNull( result ) ||
			!isBoolean( result ) ||
			result
			){
			
			return( true );
			
		}
		
		// If we made it this far, the request should not processed.
		return( false );
		
	}
	
	
	// I determine if the given user can subscribe to the given channel.
	function allowSubscribe( requestInfo ){
		
		// Re-instantiate the target application.
		this.application = new Application();
		
		// Check to see if the application will process this event.
		if (!structKeyExists( this.application, "onWSRequestStart" )){
			
			// Nothing to do.
			return( true );
			
		}
	
		// Pass this off to the application for processing.
		var result = this.application.onWSRequestStart(
			"subscribe",
			requestInfo.channelName,
			this.normalizeConnection( requestInfo.connectionInfo )
		);
		
		// Check to see if the request should be processed.
		if (
			isNull( result ) ||
			!isBoolean( result ) ||
			result
			){
			
			return( true );
			
		}
		
		// If we made it this far, the request should not processed.
		return( false );
		
	}
	
	
	// I initialize the message publication, allowing an opportunity
	// to format and manipulate the message.
	function beforePublish( message, requestInfo ){
		
		// Check to see if the application will process this event.
		if (!structKeyExists( this.application, "onWSRequest" )){
			
			// Nothing to do.
			return( message );
			
		}
		
		// Pass this off to the application for processing.
		var result = this.application.onWSRequest(
			requestInfo.channelName,
			this.normalizeConnection( requestInfo.connectionInfo ),
			message
		);
		
		// Return the new message.
		return( result );
		
	}
	
	
	// I initialize the message sending, allowing an opportunity to
	// format and manipulate a message before it is sent to the 
	// given user.
	function beforeSendMessage( message, requestInfo ){
	
		// Check to see if the application will process this event.
		if (!structKeyExists( this.application, "onWSResponse" )){
			
			// Nothing to do.
			return( message );
			
		}
		
		// Pass this off to the application for processing.
		var result = this.application.onWSResponse(
			requestInfo.channelName,
			this.normalizeConnection( requestInfo.connectionInfo ),
			message
		);
		
		// Return the new message.
		return( result );
	
	}
	
	
	// I determine if the given message should be sent to the given 
	// client. This is invoked for EVERY client that is subscribed to
	// to the given channel.
	function canSendMessage( message, subscriberInfo, publisherInfo ){
		
		// Check to see if the application will process this event.
		if (!structKeyExists( this.application, "onWSResponseStart" )){
			
			// Nothing to do.
			return( true );
			
		}

		// Pass this off to the application for processing.
		var result = this.application.onWSResponseStart(
			subscriberInfo.channelName,
			this.normalizeConnection( subscriberInfo.connectionInfo ),
			this.normalizeConnection( publisherInfo.connectionInfo ),
			message
		);
		
		// Check to see if the response should be processed.
		if (
			isNull( result ) ||
			!isBoolean( result ) ||
			result
			){
			
			return( true );
			
		}
		
		// If we made it this far, the response should not processed.
		return( false );
		
	}
	
	
	// I normalize the connection infor making sure that is has the 
	// following fields:
	// 
	// - authenticated
	// - clientID
	// - connectionTime
	//
	// If a channel has no subscribers or a message is published from
	// the server, this information will be missing. To make 
	// processing easier, we're just gonna fill it in with defaults.	
	function normalizeConnection( connection ){
		
		// Check to see if this connection is missing information.
		if (isNull( connection.clientid )){
			
			// Normalize. We're using quoted values to mimic the JSON
			// keys that would have come across the connection.
			connection[ "authenticated" ] = "NO";
			connection[ "clientid" ] = 0;
			connection[ "connectiontime" ] = now();
			
		}
		
		// Return the normalized connection.
		return( connection );
				
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

































