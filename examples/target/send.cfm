
<!--- Param our User ID variable. --->
<cfparam name="url.id" type="numeric" default="0" />

<!--- Check to see if a user ID has been selected. --->
<cfif url.id>
	
	<!--- 
		Loop over the application users to find one with the same ID
		so we can send a message to that user.
	--->
	<cfloop
		index="user"
		array="#application.users#">
	
		<!--- 
			Check to see if this user record is the one we're going 
			to be sending a message to.
		--->
		<cfif (user.id eq url.id)>
			
			<!--- 
				Push a message to a SPECIFIC user (NOTE: This may 
				be multiple clients, depending on the user's browser 
				configuration).
			--->
			<cfset wsPublish(
				"demo",
				{
					text: "Hello #user.name#, I hope you are well.",
					targetUserID: user.id
				}
			) />
			
			
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
		Send A Message To A User
	</h1>
	
	<ul>
		<cfoutput>
		
			<!--- 
				Output a link to send a static message to each of 
				the users. 
			--->
			<cfloop
				index="user"
				array="#application.users#">
				
				<li>
					<a href="./send.cfm?id=#user.id#">
						Send to #user.name#
					</a>
				</li>
				
			</cfloop>
		
		</cfoutput>
	</ul>
	
</body>
</html>












