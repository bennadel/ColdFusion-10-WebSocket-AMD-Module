
<!--- Param the FORM fields. --->
<cfparam name="form.submitted" type="boolean" default="false" />
<cfparam name="form.name" type="string" default="" />


<!--- 
	Check to see if the form was submitted and the user's name has 
	been provided. 
--->
<cfif (
	form.submitted && 
	len( form.name )	
	)>

	<!--- Flag the user as logged-in. --->
	<cfset session.isLoggedIn = true />
	<cfset session.name = form.name />

	<!--- Redirect to home page. --->
	<cflocation
		url="./index.cfm"
		addtoken="false"
		/>

</cfif>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Turn off debugging output. --->
<cfsetting showdebugoutput="false" />

<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<!doctype html>
<html>
<head>
	<meta charset="utf-8">
	<title>Using ColdFusion 10 WebSocket Sessions</title>
</head>
<body>
	
	<h1>
		Please Log-In
	</h1>
	
	<form action="./" method="post"">
		
		<!--- Flag form submission. --->
		<input type="hidden" name="submitted" value="true" />
		
		<p>
			Enter Your Name:<br /> 
			<input type="text" name="name" size="30" />
			<input type="submit" value="Log-In" />
		</p>
		
	</form>
		
</body>
</html>














