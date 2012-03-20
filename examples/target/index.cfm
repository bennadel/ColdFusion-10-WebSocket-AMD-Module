
<!--- Param our User ID variable. --->
<cfparam name="url.id" type="numeric" default="0" />

<!--- Check to see if a user ID has been selected. --->
<cfif url.id>
	
	<!--- 
		Loop over the application users to find one with the same ID
		so we can property configure this user. 
	--->
	<cfloop
		index="user"
		array="#application.users#">
	
		<!--- 
			Check to see if this user record is the one we're going 
			to be logged-in as. 
		--->
		<cfif (user.id eq url.id)>
			
			<!--- Configure the user's session. --->
			<cfset session.id = user.id />
			<cfset session.name = user.name />
			
			<!--- Send user to the main page. --->
			<cflocation
				url="./user.cfm"
				addtoken="false"
				/>
			
		</cfif>
	
	</cfloop>
	
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
	<title>Using ColdFusion 10 WebSockets To Target A User</title>
</head>
<body>
	
	<h1>
		Select A User
	</h1>
	
	<ul>
		<cfoutput>
		
			<!--- Output a link to log-in as each user. --->
			<cfloop
				index="user"
				array="#application.users#">
				
				<li>
					<a href="./index.cfm?id=#user.id#">#user.name#</a>
				</li>
				
			</cfloop>
		
		</cfoutput>
	</ul>
	
</body>
</html>












