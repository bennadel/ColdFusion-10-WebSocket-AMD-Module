
<!--- Check to make sure the user has logged-in. --->
<cfif !session.id>
	
	<!--- Redirect back to login. --->
	<cflocation 
		url="./index.cfm" 
		addtoken="false"
		/>
	
</cfif>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Turn off debugging output. It can't help us in WebSockets. --->
<cfsetting showdebugoutput="false" />

<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<!doctype html>
<html>
<head>
	<meta charset="utf-8">
	<title>Using ColdFusion 10 WebSockets To Target A User</title>
	
	<script type="text/javascript">
		<cfoutput>
	
			// We need to pass the Application name through with the
			// WebSocket connection so ColdFusion knows which memory
			// space to access. 
			var coldfusionAppName = "#getApplicationMetaData().name#";
			
			// Let's pass the user ID through with each WebSocket 
			// request. This way, we can associate the WebSocket 
			// requests with the appropriate session on the server.
			var coldfusionUserID = #session.id#;
			
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
	<cfoutput>	
		
		<h1>
			Hello, I'm #session.name# 
		</h1>
		
		<p>
			Check out my <em>JavaScript console</em> - that's where 
			my messages show up.
		</p>
		
	</cfoutput>
</body>
</html>












