
<!--- Param our User ID variable. --->
<cfparam name="url.id" type="numeric" default="0" />

<!--- Check to see if a user ID has been selected. --->
<cfif url.id>
	
	<!--- 
		Loop over the application users to find one with the same ID
		so we can send a message to that user.
	--->
	<cfloop
		index="pushUser"
		array="#application.users#">
	
		<!--- 
			Check to see if this user record is the one we're going 
			to be sending a message to.
		--->
		<cfif (pushUser.id eq url.id)>
			
			<!--- 
				Push a message to a SPECIFIC user (NOTE: This may 
				be multiple clients, depending on the user's browser 
				configuration - this will push a message to any 
				client that has subscribed with the given UserID).
			--->
			<cfset wsPublish(
				"demo",
				"Hello #pushUser.name#, I hope you are well.",
				{
					selector: "userID eq #pushUser.id#"
				}
			) />
			
			<!--- We found the user, no need to keep looping. --->
			<cfbreak />
			
		</cfif>
	
	</cfloop>
	
</cfif>


<!--- ----------------------------------------------------- --->
<!--- ----------------------------------------------------- --->


<!--- Turn off debugging output. --->
<cfsetting showdebugoutput="false" />

<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<cfoutput>
		
	<!doctype html>
	<html>
	<head>
		<meta charset="utf-8">
		<title>Using ColdFusion 10 WebSocket Native Filtering</title>
	</head>
	<body>
		
		<h1>
			Send A Message To A User
		</h1>
		
		<ul>
			
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
			
		</ul>
		
		
		<!--- Check to see if we have a user we pushed to. --->
		<cfif !isNull( pushUser )>
			
			<p>
				Pushed to #pushUser.name#!
			</p>
			
		</cfif>
		
	</body>
	</html>

</cfoutput>










