
// I am not sure that we *have* to set these values. But, for now, let's dump them
// into the global scope in case the dependent scripts (in the CFIDE folder) need them.
//
// Notice that we are allowing a pre-existing setting of these values, which will take 
// presedence over our internal values. Therefore, if they have already been defined in
// the global scope, then we will not override those values.
(function(){
	
	// Set our default properties (these will only be used if the 
	// property is not already defined).
	var defaults = {
		_cf_loadingtexthtml: "<img src='about:blank' />",
		_cf_contextpath: "",
		_cf_ajaxscriptsrc: "/CFIDE/scripts/ajax",
		_cf_jsonprefix: "//",
		_cf_websocket_port: 8585
	};
	
	// Loop over the defaults to apply if necessary.
	for ( key in defaults ){
		
		this[ key ] = (this[ key ] || defaults[ key ]);
		
	}
	
}).call( null );


// Define our ColdFusoin WebSocket wrapper. This code depends on the
// loading of the CFIDE scripts. Since these are not AMD compliant, 
// we'll put them as the last arguments (and they will not come 
// through as invocation parameters).
//
// NOTE: We are using the "order!" plugin to make sure the ColdFusion
// scripts load in the given order. The various libraries depend on 
// the CFMessage object, so it must be loaded first. 
define(
	[
		"jquery",
		("order!" + _cf_ajaxscriptsrc + "/messages/cfmessage.js"),
		("order!" + _cf_ajaxscriptsrc + "/package/cfajax.js"),
		("order!" + _cf_ajaxscriptsrc + "/package/cfwebsocketCore.js"),
		("order!" + _cf_ajaxscriptsrc + "/package/cfwebsocketChannel.js")
	],
	function( $ ){
		
		
		// Version number (no functional value).
		var version = "0.3.0";
		
		
		// Check to see if we need to "Fill" the JSON object.
		if (!window.JSON){
			
			// Since this browser doesn't support the JSON object, we
			// can polyfill it using the underlying ColdFusion 
			// encoder and decoder.
			window.JSON = {
				stringify: function( value ){
					return( ColdFusion.JSON.encode( value ) );
				},
				parse: function( value ){
					return( ColdFusion.JSON.decode( value ) );
				}
			};
			
		}
		
		
		// I return an initialized ColdFusion WebSocket wrapper. Each
		// WebSocket represents one connection. Multiple channels can
		// be subscribed-to over the single connection. All connections
		// are meant to be to the same application.
		function ColdFusionWebSocket( applicationName, channels, headers ){
			
			var self = this;
		
			// Check to see if the channels is a string. If so, let's just split
			// it on the comma, assuming that multiple channels may have been 
			// passed-in.
			if (Object.prototype.toString.call( channels ) === "[object String]"){
				
				// Split into an array.
				channels = channels.split( "," );
				
			}
			
			// Store the ColdFusion application name. This is required when
			// making the WebSocket connection so that the correct server-side
			// memory space is invoked.
			this._applicationName = applicationName;
			
			// Store the custom request headers that we'll pass through with all of the
			// outgoing requests.
			this._headers = headers;
		
			// This is the underlying Socket connection / ColdFusion 
			// WebSocket object that we are decorating.
			this._socket = null;
			
			// This is the unique client ID that will be assigned to
			// this client (by the server) once the connection has
			// been established. 
			this._clientID = null;
			
			// These are the event types and subscriptions for the 
			// channel. Each subscription will consist of a 
			// subscriber, a context (for the callback), and a channel.
			this._subscriptions = {
				"authenticate": [],
				"close": [],
				"error": [],
				"message": [],
				"open": [],
				"publish": [],
				"subscribe": [],
				"welcome": []
			};
			
			// I keep a collection of outstanding subscriber count
			// deferred objects by channel.
			this._deferredSubscriberCount = {};
			
			// I keep the outstanding subscriptions request deferred
			// result.
			this._deferredSubscriptions = null;
			
			// I keep the outstanding authenticate request deferred
			// result. 
			this._deferredAuthenticate = null; 
			
			// I handle the raw MESSAGE event from the underlying 
			// ColdFusion socket. I will simplify it and trigger the
			// appropriate event handlers.
			var messageHandler = function( event ){
				
				// console.log( "MESSAGE[ " + (event.reqType || "data") + " ]:" );
				// console.log( event );
				
				// Check to see which type of message we are dealing
				// with so we know how to route it in our event system.
				switch (event.reqType || "data"){
					
					case "authenticate":
					
						// Resolve any outstanding authenticate promise.
						self._resolveAuthenticatePromise();
						
						// Trigger the public event as well.
						self._trigger( "authenticate", null, null, event );
						
					break;
					
					case "data":
					
						// Trigger the public event.
						self._trigger( "message", event.channelname, event.data, event );
					
					break;
					
					case "getSubscriberCount":
					
						// Resolve any outstanding subscriber count 
						// promises.
						self._resolveSubscriberCountPromise( 
							event.channel,
							event.subscriberCount
						);
					
					break;
					
					case "getSubscriptions":
					
						// Resolve any outstanding subscriptions 
						// request promise.
						self._resolveSubscriptionsPromise( event.channels );
						
					break;	
					
					case "publish":
					
						// Trigger the public event.
						self._trigger( "publish", null, null, event );
					
					break;
					
					case "subscribeTo":
						
						// Trigger the public event. Since multiple 
						// channels may be subscribed at one time, 
						// let's try to split the values.
						$.each(
							(event.channelssubscribedto || "").split( "," ),
							function( i, channel ){
								
								self._trigger( "subscribe", channel, null, event );
								
							}
						);
						
					break;
					
					case "welcome":
					
						// Store the client ID. This will remain
						// consistent for the duration of this
						// connection to the server.
						self._clientID = event.clientid;
						
						// Trigger the public event.
						self._trigger( "welcome", null, null, event );
					
					break;
					
				}
				
			};
			
			// I handle the raw OPEN event from the underlying 
			// ColdFusion socket. I will simplify the data and 
			// trigger the appropriate event handlers.
			var openHandler = function(){
				
				// Simply trigger the event.
				self._trigger( "open", null, null, null );
				
			};
			
			// I handle the raw CLOSE event from the underlying
			// ColdFusion socket. I will simplify the data and 
			// trigger the appropriate event handlers.
			var closeHandler = function( event ){
				
				// Simply trigger the public event.
				self._trigger( "close", null, null, event );
				
			};
			
			// I handle the raw ERROR event from the underlying
			// ColdFusino socket. I will simplify the data and
			// trigger the appropriate event handlers.
			var errorHandler = function( event ){
				
				// console.log( "ERROR" );
				// console.log( event );
				
				// Check to see if we have an error that we can pipe into 
				// a more appropriate response event.
				switch (event.reqType){
					
					case "authenticate":
					
						// Reject any outstanding authenticate promise.
						self._rejectAuthenticatePromise();
						
					break;
					
					default:
					
						// Generic error. Simply trigger the public event.
						self._trigger( "error", null, (event.msg || ""), event );
					
					break;
					
				}
				
			};
			
			// Initialize the underlying ColdFusion web socket.
			// This object will be bound to our intermediary event
			// handlers which will interpret the responses.
			//
			// NOTE: We are subscribing to the channels AFTER the socket has been created
			// so that we can attach custom headers.
			this._socket = ColdFusion.WebSocket.init(
				"socket",
				this._applicationName,
				"", // User ID used with native CFLogin system - we're not using this.
				"", // Comma-delimited list of channels.
				messageHandler,
				openHandler,
				closeHandler,
				errorHandler,
				location.pathname // Referrer.				
			);
			
			// Once the connect has been opened, we want to perform a one-time-only 
			// initial subscribe of the given channels.
			var initialSubscribeOnly = function(){
				
				// Unbind the open-handler - we only want to do this once.
				self.off( "open", initialSubscribeOnly );
				
				// Now that WebSocket connection has been opened, loop over the given
				// channels to subscribe them individually. We're using this approach,
				// as opposed to the .init() approach so that we can send headers with
				// each subscription request.
				for (var i = 0 ; i < channels.length ; i++){
					
					self.subscribe( channels[ i ] );
					
				}
				
			};
			
			// Bind the open event so we can subscribe once the WebSocket has been
			// connected to the ColdFusion server.
			this.on( "open", initialSubscribeOnly );
			
			// Return this object reference.
			return( this );
						
		}
		
		
		// Define the class methods.
		ColdFusionWebSocket.prototype = {
			
			
			// I authenticate the given credentials against the 
			// ColdFusion server. I return a promise that will be resolved
			// upon successful authentication, or rejected upon failed
			// authentication.
			authenticate: function( username, password ){
				
				// Check to see if there is a currently outstanding
				// request for authentication.
				if (!this._deferredAuthenticate){
					
					// Create a new Deferred object for this authentication request.
					var deferred = $.Deferred();
					
					// Store the deferred.
					this._deferredAuthenticate = deferred;
					
					// Initiate the asynchronous request for the authentication.
					this._socket.authenticate( username, password );
					
				}
				
				// Return the promise for authentication.
				return(
					this._deferredAuthenticate.promise()
				);
				
			},
			
			
			// I close the underlying connection.
			closeConnection: function(){
				
				// Pass this off to the underlying socket.
				this._socket.closeConnection();
				
				// Return this reference for method chaining.
				return( this );
				
			},
			
			
			// I get the client ID assigned to this client for the
			// current connection to the server.
			getClientID: function(){
				
				return( this._clientID );
				
			},
			
			
			// I return the subscriber count for the given channel. 
			// Since this request is asynchronous, I return a promise
			// of data to be returned.
			getSubscriberCount: function( channel ){
				
				// Return promise.
				return( 
					this._getSubscriberCountPromise( channel ) 
				);
				
			},
			
			
			// I get the Deferred result for the given subscription 
			// count. If it not yet created, I'll create a new one.
			_getSubscriberCountPromise: function( channel ){
				
				// Check to see if there is any currently outstanding
				// request for the given count.
				if (!this._deferredSubscriberCount.hasOwnProperty( channel )){
					
					// Create a new Deferred object for this 
					// subscription count request.
					var deferred = $.Deferred();
					
					// Store the deferred.
					this._deferredSubscriberCount[ channel ] = deferred;
					
					// Initiate the asynchronous request for the 
					// subscriber count on the given channel.
					this._socket.getSubscriberCount( channel );
					
				}
				
				// Return the promise for subscriber count.
				return(
					this._deferredSubscriberCount[ channel ].promise()
				);
				
			},
			
			
			// I return the collection of all channels the current
			// connection is subscribed to (as an array). Since this 
			// is an asynchronous process, I'll return a Deferred
			// result.
			getSubscriptions: function(){
				
				// Check to see if there is an outstanding request 
				// for the current subscriptions.
				if (this._deferredSubscriptions === null){
					
					// Create a new Deferred object for this 
					// subscription count request.
					var deferred = $.Deferred();
					
					// Store the deferred.
					this._deferredSubscriptions = deferred;
					
					// Initiate the asynchronous request for the 
					// current subscriptions.
					this._socket.getSubscriptions();
					
				}
								
				// Return the promise of subscriptions.
				return( this._deferredSubscriptions.promise() );
				
			},
			
			
			// I check to see if the underlying WebSocket connection 
			// is open. Returns true if open.
			isConnectionOpen: function(){
				
				// Pass this off to the underlying socket.
				return( this._socket.isConnectionOpen() );
				
			},
			
			
			// I check to see if one channel is a sub-channel of 
			// another.
			_isSubChannel: function( channel, subChannel ){
				
				// Check to see if the sub-channel starts the channel.
				return(
					(channel === subChannel) ||
					(subChannel.indexOf( channel + "." ) === 0)
				);
				
			},
			
			
			// I remove an event binding on the given event for the
			// given callback.
			off: function( eventType, callback ){
				
				// Get the current list of subscribers.
				var subscriptions = this._subscriptions[ eventType ];
				
				// Map the collection back onto itself, removing the
				// given callback (if necessary).
				subscriptions = $.map(
					function( i, subscription ){
						
						// Check to see if this is the callback we
						// want to remove.
						if (subscription.callback === callback){
							
							// Return NULL to remove this from the
							// resulting collection.
							return( null );
							
						}
						
						// If we made it this far, we're going to keep
						// this subscription. Return it so that it is
						// folded into the resultant collection.
						return( subscription );
						
					}
				);
				
				// Reset the subscription collection.
				this._subscriptions[ eventType ] = subscriptions;
				
				// Return this reference for method chaining.
				return( this );
				
			},
			
			
			// I create an event binding to the given event on the 
			// given channel. An optional context can be provided
			// for callback invocation.
			on: function( eventType /*, channel, callback, context */ ){
				
				// Set up the default, optional arguments binding.
				var channel = arguments[ 1 ];
				var callback = arguments[ 2 ];
				var context = arguments[ 3 ];
				
				// Check for optional arguments.
				if (arguments.length === 2){
					
					// Only event and callback provided.
					channel = null;
					callback = arguments[ 1 ];
					context = window;
					
				} else if (arguments.length === 3){
					
					// Check to see if the second argument is a String.
					// If so, it's the context that's missing.
					if (Object.prototype.toString.call( arguments[ 1 ] ) === "[object String]"){
						
						// Context is missing.
						channel = arguments[ 1 ];
						callback = arguments[ 2 ];
						context = window;
						
					} else {
						
						// Channel is missing.
						channel = null;
						callback = arguments[ 1 ];
						context = arguments[ 2 ];
						
					}
					
				}
				
				// Create the subscription.
				this._subscriptions[ eventType ].push({
					channel: channel,
					callback: callback,
					context: context
				});
				
				// Return this reference for method chaining.
				return( this );
				
			},
			
			
			// I open the underlying connection if it has been closed.
			openConnection: function(){
				
				// Pass this along to the underlying socket.
				this._socket.openConnection();
				
				// Return this reference for method chaining.
				return( this );
				
			},
			
			
			// I deserialize the given JSON value.
			parse: function( jsonValue ){
				
				return( window.JSON.parse( jsonValue ) );
				
			},
			
			
			// I publish the given message to the given channel.
			publish: function( channel, data, headers ){
				
				// Compile a collection of provided headers with the cached headers to 
				// determine what our outgoing headers will be.
				var publishHeaders = $.extend(
					{},
					headers,
					this._headers
				);
				
				// Pass this along to the underlying socket.
				this._socket.publish( channel, data, publishHeaders );
				
				// Return this reference for method chaining.
				return( this );
				
			},
			
			
			// I reject any outstanding deferred result authentication.
			_rejectAuthenticatePromise: function(){
				
				// Check to see if we have an outstanding promise.
				if (!this._deferredAuthenticate){
					
					// Nothing to do, just exit.
					return;
					
				}
				
				// Reject the deferred result.
				this._deferredAuthenticate.reject();
				
				// Clear the deferred object.
				this._deferredAuthenticate = null;
				
			},
			
			
			// I resolve any outstanding deferred result authentication.
			_resolveAuthenticatePromise: function(){
				
				// Check to see if we have an outstanding promise.
				if (!this._deferredAuthenticate){
					
					// Nothing to do, just exit.
					return;
					
				}
				
				// Resolve the deferred result.
				this._deferredAuthenticate.resolve();
				
				// Clear the deferred object.
				this._deferredAuthenticate = null;
				
			},
			
			
			// I resolve any outstanding deferred result for 
			// subscriber count on the given channel.
			_resolveSubscriberCountPromise: function( channel, count ){
				
				// Check to see if we have an outstanding promise.
				if (!this._deferredSubscriberCount.hasOwnProperty(channel)){
					
					// Nothing to do, just exit.
					return;
					
				}
				
				// Resolve the deferred result.
				this._deferredSubscriberCount[ channel ].resolve( count );
				
				// Remove the deferred object from our collection - 
				// we won't need to deal with it again.
				delete( this._deferredSubscriberCount[ channel ] );
				
			},
			
			
			// I resolve the outstanding deferred result for a
			// request to get current subscriptions.
			_resolveSubscriptionsPromise: function( channels ){
				
				// Check to see if we have an outstanding promise.
				if (this._deferredSubscriptions === null){
					
					// Nothing to do, just exit.
					return;
					
				}
				
				// Resolve the deferred result.
				this._deferredSubscriptions.resolve( channels );
				
				// Remove the deferred object - we won't need to deal 
				// with it again.
				this._deferredSubscriptions = null;
				
			},
			
			
			// I convert the given value to JSON.
			stringify: function( value ){
				
				return( window.JSON.stringify( value ) );
				
			},
			
			
			// I subscribe to the given channel, if not already
			// subscribed.
			subscribe: function( channel, headers ){
				
				// Compile the provided headers with the cached headers to determine what
				// we'll be sending with out outgoing request.
				var subscribeHeaders = $.extend(
					{},
					headers,
					this._headers
				);
				
				// Pass this along to the underlying socket. We are 
				// not going to allow per-channel listeners since that
				// kind of differentiation will be handled in our
				// event-bind functionality.
				this._socket.subscribe( channel, subscribeHeaders );
				
				// Return this reference for method chaining.
				return( this );
				
			},
			
			
			// I trigger the given event on all the currently-bound
			// subscribers.
			_trigger: function( eventType, channel, data, originalEvent ){
				
				// Create an event object.
				var event = {
					type: eventType,
					channel: channel,
					originalEvent: originalEvent,
					isEcho: false
				};
				
				// Check to see if this event is an "Echo". By that,
				// I mean, did it originate from this client? Or, did
				// it come from a different client.
				if (
					originalEvent && 
					originalEvent.hasOwnProperty( "publisherid" ) &&
					(originalEvent.publisherid === this._clientID)
					){
						
					// It appears that this came from "self".
					event.isEcho = true;
					
				}	
				
				// Flatten the data to the end of the event to create
				// a collection of arguments for triggering.
				var triggerArguments = [ event ].concat( data || [] );
				
				// Get the subscriptions on the current event type.
				var subscriptions = this._subscriptions[ eventType ];
				
				// Loop over the subscriptions to access the ones 
				// on the given channel.
				for (var i = 0 ; i < subscriptions.length ; i++){
					
					// Check to see if the subscription is for the
					// specified channel. Not all event types require
					// a channel. As such, if triggered-channel is
					// NULL then we'll invoke the subscriber.
					if (
						(channel == null) ||
						this._isSubChannel( subscriptions[ i ].channel, channel )
						){
						
						// Trigger the event.
						subscriptions[ i ].callback.apply(
							subscriptions[ i ].context,
							triggerArguments
						);
						
					}
					
				} 				
				
			},
			
			
			// I unsubscribe from the given channel (or channels). 
			// Multiple channels can be passed-in.
			unsubscribe: function( channel ){
				
				// Pass this along to the underlying socket.
				for (var i = 0 ; i < arguments.length ; i++){
				
					this._socket.unsubscribe( arguments[ i ] );
					
				}
				
				// Return this reference for method chaining.
				return( this );
				
			}
			
			
		};


		// -------------------------------------------------- //
		// -------------------------------------------------- //


		// Return the constructor for the CF WebSocket class.
		return( ColdFusionWebSocket );
		
		
	}
);














































