
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
		dom.publish = $( "a.publish" );
		
		
		// Create an instance of our ColdFusion WebSocket module
		// and subscribe to the "Demo" channel. We are setting the
		// CFID and CFTOKEN values as custom headers that will be
		// passed-through with each socket request. This way, we 
		// can bind the WebSocket session to the native ColdFusion 
		// session.
		var socket = new ColdFusionWebSocket( 
			coldfusionAppName,
			"demo",
			{
				cfid: coldfusionSession.cfid,
				cftoken: coldfusionSession.cftoken
			}
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

		
		// Bind to the publish link so this client can broadcast a
		// message to all subscribed users.
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



