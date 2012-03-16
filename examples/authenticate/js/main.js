
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


// Load the application. In order for the demo controller to 
// run, we need to wait for jQuery and the CFWebSocket module to 
// become available.
require(
	[
		"jquery",
		"../../../cfwebsocket",
		"domReady"
	],
	function( $, ColdFusionWebSocket ){
	
		
		// Cache the DOM elements that we'll need in this demo.
		var dom = {};
		dom.form = $( "form" );
		dom.username = $( "input[ name = 'username' ]" );
		dom.password = $( "input[ name = 'password' ]" );
		dom.publish = $( "a.publish" );
		
		// Create an instance of our ColdFusion WebSocket module
		// and subscribe to the "Demo" channel.
		var socket = new ColdFusionWebSocket(
			$( "html" ).attr( "data-app-name" ),
			"demo" 
		);

		
		// Listen for published messages on the "Demo" channel.
		socket.on(
			"message",
			"demo",
			function( event, data ){
				
				console.log( "Published:", data );
				
			}
		);
		
		
		// Listen for publish errors.
		socket.on(
			"error",
			function( event, message ){
				
				console.log( "Error:", message );
				
			}
		);
		
		
		// Bind to the form submission so we can pipe the request
		// through our ColdFusion WebSocket connection.
		dom.form.submit(
			function( event ){
				
				// Prevent the form submission.
				event.preventDefault();
				
				// Get the user's credentials.
				var username = dom.username.val();
				var password = dom.password.val();
				
				console.log( "Authenticating..." );
				
				// Authenticate! This will return a promise that
				// we can bind to.
				var login = socket.authenticate( username, password );
				
				// Look at the success and error handlers to see if
				// the authentication worked.
				login.then(
					function(){
						console.log( "Authenticate Success!" );
					},
					function(){
						console.log( "Authenticate Failure!" );
					}
				);
				
			}
		);
		
		
		// Bind to the publish link so we can try publishing when
		// we have different authentication states.
		dom.publish.click(
			function( event ){
				
				// Kill the default click behavior - this is not a 
				// real link.
				event.preventDefault();
				
				// Publish something!
				socket.publish( "demo", "This is a test message." );
				
			}
		);
		

	}
);



