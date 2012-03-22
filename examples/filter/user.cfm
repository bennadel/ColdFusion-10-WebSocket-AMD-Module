
<!--- Param the user's selected persona. --->
<cfparam name="url.id" type="numeric" default="0" />
<cfparam name="url.name" type="string" default="" />

<!--- Make sure the user has selected a persona. --->
<cfif !url.id>
	
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
	<title>Using ColdFusion 10 WebSocket Native Filtering</title>
	
	<script type="text/javascript">
		<cfoutput>
	
			// We need to pass the Application name through with the
			// WebSocket connection so ColdFusion knows which memory
			// space to access. 
			var coldfusionAppName = "#getApplicationMetaData().name#";
			
			// Let's pass the user ID through with each WebSocket 
			// request. This way, we can use implicit WebSocket 
			// filtering on the server-side.
			var coldfusionUserID = #url.id#;
			
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
			Hello, I'm #url.name# 
		</h1>
		
		<p>
			Check out my <em>JavaScript console</em> - that's where 
			my messages show up.
		</p>
		
		<p>
			<a href="./index.cfm">Choose a differen user</a>.
		</p>
		
	</cfoutput>
</body>
</html>












