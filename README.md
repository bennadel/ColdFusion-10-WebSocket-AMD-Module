# ColdFusion 10 WebSocket AMD Compliant(ish) Module

## Constructor

```ColdFusionWebSocket( coldfusionAppName [, channel [, headers]] )```

The first argument, coldfusionAppName, is the name of your server-side ColdFusion application as determined by the "this.name" value you define in your Application.cfc. If you this is not an easy accessible value, you can always access it using the getApplicationMetaData() method.

## Public Methods

* authenticate( username, password ) :: Promise
* closeConnection()
* getClientID() :: Int
* getSubscriberCount( channel ) :: Promise
* getSubscriptions() :: Promise
* isConnectionOpen() :: Boolean
* off( eventType, callback )
* on( eventType [, channel], callback [, context] )
* openConnection()
* parse( json ) :: Any
* publish( channel, data [, headers] )
* stringify( value ) :: JSON
* subscribe( channel [, headers] )
* unsubscribe( channel )