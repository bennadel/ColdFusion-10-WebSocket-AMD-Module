
// Define the paths to be used in the script mappings. Also, define
// the named module for certain libraries that are AMD compliant.
require.config({
	baseUrl: "js/",
	paths: {
		"domReady": "lib/require/domReady",
		"jquery": "lib/jquery/jquery-1.7.1",
		"order": "lib/require/order",
		"text": "lib/require/text",
	}
});


// Load the application. In order for the Chat controller to run,
// we need to wait for jQuery and the CFWebSocket module be available.
require(
	[
		"jquery",
		"../../../cfwebsocket",
		"domReady"
	],
	function( $, ColdFusionWebSocket ){
	
		
		// I activate all the form fields.
		function activateForm(){
			
			dom.handle.removeAttr( "disabled" );
			dom.message.removeAttr( "disabled" );
			dom.submit.removeAttr( "disabled" );
			
			// Focus the handle input.
			dom.handle.focus().select();
			
		}
		
		
		// I add the given message to the chat history.
		function addMessage( handleData, messageData ){
			
			var handle = $( "<span />" )
				.text( handleData + ":" )
				.addClass( "handle" )
			;
			
			var message = $( "<span />" )
				.text( messageData )
				.addClass( "message" )
			;
			
			var item = $( "<li />" )
				.addClass( "message" )
				.append( handle )
				.append( message )
			;
			
			// Add the new history item.
			dom.chatHistory.append( item );
			
		}
		
		
		// I deactivate all the form fields.
		function deactivateForm(){
			
			dom.handle.attr( "disabled", "disabled" );
			dom.message.attr( "disabled", "disabled" );
			dom.submit.attr( "disabled", "disabled" );
			
		}
		
		
		// I log the given event to the chat history.
		function logEvent( description ){
			
			var item = $( "<li />" )
				.text( description )
				.addClass( "event" )
			;
			
			// Add the new history item.
			dom.chatHistory.append( item );
			
		}
		
		
		// I select a random name and return it.
		function getRandomHandle(){
			
			var names = [
				"Sarah", "Joanna", "Tricia", "Ben", "Dave", "Arnold",
				"Kim", "Anna", "Kit", "Sly", "Vin", "Dwayne"
			];
			
			// Return a random name.
			return(
				names[ Math.floor( Math.random() * names.length ) ]
			);
			
		}
		
		
		// I update the room count.
		function updateRoomSize(){
			
			// Get all the users who are subscribed to the chat
			// room. Since we can't subscribe to the main "chat" 
			// channel AND a sub-channel at the same time, just get
			// all the users that are subscribed to the message sub-
			// channel. That should be good enough.
			var countPromise = socket.getSubscriberCount( "chat.message" );
			
			// When the result comes back, update the room count.
			countPromise.done(
				function( count ){
					
					dom.roomSize.text( count );
					
				}
			);
			
		}
		
		
		// -------------------------------------------------- //
		// -------------------------------------------------- //

		
		// Cache the DOM elements that we'll need in this demo.
		var dom = {};
		dom.chatHistory = $( "ol.chatHistory" );
		dom.form = $( "form" );
		dom.handle = $( "input.handle" );
		dom.message = $( "input.message" );
		dom.submit = $( "input.submit" );
		dom.roomSize = $( "p.chatSize span.count" );
		
		// Create an instance of our ColdFusion WebSocket module
		// and subscribe to several "chat" sub-channels. We're using
		// sub-channels so we can have more fine-tuned control over
		// how we respond to messages.
		var socket = new ColdFusionWebSocket(
			$( "html" ).attr( "data-app-name" ),
			[
				"chat.message",
				"chat.userlist.subscribe",
				"chat.userlist.unsubscribe"
			]			
		);
		
		// Set a random handle.
		dom.handle.val( getRandomHandle() );
		
		// Let the user know that we are connecting.
		logEvent( "Connecting to ColdFusion server." );
		
		// Disable the form elements until the socket has been 
		// connected. We don't want people trying to push messages
		// until the subscription is open - that would cause an error.
		deactivateForm();
		
		// When the socket has connected, activate the form.
		socket.on(
			"open",
			function(){
				
				// Let the user know we have connected.
				logEvent( "Connected." );
				
				// Activate the form.
				activateForm();
				
				// Update the room-size.
				updateRoomSize();
				
			}
		);
		
		
		// When a message comes down in the "message" sub-channel, we
		// want to display it in the chat history.
		socket.on(
			"message",
			"chat.message",
			function( event, responseData ){
				
				// Deserialize the response.
				var response = socket.parse( responseData );
				
				// Add the message to the chat.
				addMessage( response.handle, response.message );
				
			}
		);
		
		
		// When the a new user has entered or left the chat room, we 
		// want to announce the event and update the subsriber count.
		socket.on(
			"message",
			"chat.userlist",
			function( event, responseData ){
				
				// Check to see which sub-channel we are using.
				if (event.channel === "chat.userlist.subscribe"){
					
					// Deserialize the data for our new user.
					var user = socket.parse( responseData );
					
					// Log subscription event.
					logEvent( 
						"A new user has entered the chat [ " + 
						user.clientid + " ]." 
					);
					
				} else {
					
					// Log the unsubscription event.
					logEvent( "A user has left the chat." );
					
				}
				
				// Update the room size.
				updateRoomSize();
				
			}
		);
		
		
		// Bind to the form submission so we can pipe the request
		// through our ColdFusion WebSocket connection.
		dom.form.submit(
			function( event ){
				
				// Prevent the form submission.
				event.preventDefault();
				
				// Get the cleaned form values. For this demo, we're
				// not going to do any real error handling. No need
				// to further complicate an ALREADY complex system.
				var handle = (dom.handle.val() || "User");
				var message = (dom.message.val() || "");
				
				// Publish the message, including the handle that
				// the user has chosen.
				socket.publish( 
					"chat.message",
					{
						handle: handle, 
						message: message
					}
				);
				
				// Post the local copy directly to the chat history.
				addMessage( handle, message );
				
				// Clear the message form and re-focus it.
				dom.message
					.val( "" )
					.focus()
				;
				
			}
		);
		
		
		// When the window closes (unloads), unsubscribe the user
		// from the various channels. This way, any other user in 
		// the chat room can see what is happening.
		$( window ).bind(
			"beforeunload",
			function( event ){
				
				// Unsubscribe from all the channels.
				socket
					.unsubscribe( "chat.message" )
					.unsubscribe( "chat.userlist.subscribe" )
					.unsubscribe( "chat.userlist.unsubscribe" )
				;
				
			}
		);


	}
);



