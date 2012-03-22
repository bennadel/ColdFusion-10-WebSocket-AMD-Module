
<!--- Turn off debugging output. --->
<cfsetting showdebugoutput="false" />

<!--- Reset the output buffer. --->
<cfcontent type="text/html; charset=utf-8" />

<!doctype html>
<html>
<head>
	<meta charset="utf-8">
	<title>Using ColdFusion 10 WebSocket Native Filtering</title>
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
					<a href="./user.cfm?id=#user.id#&name=#user.name#">
						#user.name#
					</a>
				</li>
				
			</cfloop>
		
		</cfoutput>
	</ul>
	
</body>
</html>












