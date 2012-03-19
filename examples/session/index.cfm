
<!--- Turn off debugging output. It can't help us in WebSockets. --->
<cfsetting showdebugoutput="false" />

<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<!doctype html>
<html>
<head>
	<meta charset="utf-8">
	<title>Using ColdFusion 10 WebSocket Sessions</title>
	
	<script type="text/javascript">
		<cfoutput>
	
			// We need to pass the Application name through with the
			// WebSocket connection so ColdFusion knows which memory
			// space to access. 
			var coldfusionAppName = "#getApplicationMetaData().name#";
			
			// In order to bind the WebSocket "session" to the stanard
			// "user" session, we're gonna pass through the session 
			// identifiers (ID and Token). These are the SAME thing 
			// that would be in the user's cookies.
			var coldfusionSession = {
				cfid: "#session.cfid#",
				cftoken: "#session.cftoken#"
			};
			
		</cfoutput>
	</script>
	
	<!--
		Load the script loader and boot-strapping code. In this 
		demo, the "main" JavaScript file acts as a Controller for 
		the following Demo interface.
	-->
	<script 
		type="text/javascript"
		src="./js/lib/require/require.js" 
		data-main="./js/main">
	</script>
</head>
<body>
	
	<h1>
		Publish A Message
	</h1>
	
	<p>
		<a href="#" class="publish">Publish something</a>
	</p>
	
	<p>
		<em>Messages show up in console-log</em>.
	</p>
	
</body>
</html>


<!--- 
	In a brief moment, publish something from the SERVER to the 
	new user.
	
	NOTE: This will actually go to ALL users who are subscribed to
	the demo channel - for the demo, it's just me, though. 
--->
<cfthread
	name="publishFromServer"
	action="run">

	<!--- Give the client-side WebSocket time to connect. --->
	<cfset sleep( 1500 ) />
	
	<!--- Publish welcome message. --->
	<cfset wsPublish( "demo", "Welcome to my App!" ) />
	
</cfthread>












