
<!--- Turn of debugging output. It can't help us in WebSockets. --->
<cfsetting showdebugoutput="false" />

<!--- 
	We need to pass the Application name to the ColdFusion WebSocket 
	so that it knows which memory space to use. To use this, we'll 
	pass it through with the HTML element. 
--->
<cfset appName = getApplicationMetaData().name />

<!doctype html>
<html data-app-name="<cfset writeOutput( appName ) />">
<head>
	<meta charset="utf-8">
	<title>Using ColdFusion 10 WebSockets With RequireJS</title>
	
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
		Please Authenticate Your WebSocket Requests
	</h1>
	
	<form>
		<input type="text" name="username" size="20" />
		<input type="text" name="password" size="20" />
		<input type="submit" value="Authenticate" />
	</form>
	
	<p>
		<a href="#" class="publish">Publish something</a>
	</p>
	
</body>
</html>














