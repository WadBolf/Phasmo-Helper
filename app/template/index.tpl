<!DOCTYPE html>
<html>
        <head>
		<title>Phasmo Helper</title>
                <link rel="stylesheet" href="css/main.css">
                <script src="js/jquery-3.5.1.min.js"></script>
                <link rel="shortcut icon" href="favicon.ico">
        </head>
        <body>
		<div
			id="objectives-display" 
			class="objectives-container"
			onClick="editObjectives();"
		>
			OBJECTIVES (Click to set)
		</div>

		<div class="objectives-edit-container" id="objectives-edit" style="display:none">
			<div>
				<input placeholder="Ghost Name (Only first name required)" class="ghostNameInput" type="text" id="ghostNameInput" name="ghostNameInput">
			</div>
			<div id="objectives-edit-list"></div>
			<span class="reset-button" onClick="clearObjectives();">Clear Objectives</span>
			<span class="ok-button" onClick="closeEditObjectives();">Set Objectives</span>
		</div>

		<div id="select-evidences">	
			<div class="container-header" id="select-evidence-header">
				EVIDENCE
			</div>
			<div class="container-body" id="select-evidence">
			</div>
		</div>
		<div id="found-evidences" style="display:none">
			<div class="container-header" id="found-evidence-header">
				EVIDENCE FOUND
			</div>
			<div class="container-body-square" id="found-evidence">
			</div>
			<div class="container-footer" id="found-ghost-footer" >
				<span class="reset-button" onClick="resetPressed();">RESET ALL</span>
			</div>
		</div>
		<div id="found-ghosts-list" style="display:none">
			<div class="container-header" id="found-ghost-header" >
				GHOST
			</div>
			<div class="container-body" id="found-ghost" >
				NONE!
			</div>
		</div>
		<div class= "ghosts-info-container" id="found-ghosts-info-list" style="display:none">
			ALL GHOSTS INFO
			<div id="found-ghost-info" >
			</div>
		</div>
        </body>

</html>


<script>
	// Setup runtime variables
	var firstLoad = 1;
	var fullData;
	var getData = new Array(3);	
	getData[0] = "";
	getData[1] = "";
	getData[2] = "";
	var ghostName = "";
	var totalObjectives = 0;

	// AJAX funcition to get data via ajax.cgi.
	function get_data()
        {
		var jsonSearch = JSON.stringify(getData);

                var formData = {
                        func:"getdata",
			getdata:jsonSearch
                };

                $.ajax({
                        url : "ajax.cgi",
                        type: "POST",
                        data : formData,
                        success: function(data, textStatus, jqXHR)
                        {
                                lines = data.split('\n');
                                if (lines[0]=="Error:")
                                {
                                        show_error(lines[1]);
                                }
                                else
                                {
					fullData =  JSON.parse(data);
					displayPage( );
                                }

                        },
                        error: function (jqXHR, textStatus, errorThrown)
                        {
                                // AJAX errored, show a crude JavaScript
				// error alert, I'll clean this up one day!
				alert("ERROR");
                        }
                })
        }

	// Item clicked, so update fulldata, sort the array and get the updated list.
	function selectEvidence(item)
	{
		closeEditObjectives();
		getData[fullData["totalItemsFound"]] = item;
		sortData();
		get_data();
	}


	// Clear all objectives and ghost name.
	function clearObjectives()
	{
		var objectives = fullData["objectives"];
                for (var i = 0; i < objectives.length; i++)
                {
                        var spanID = "#select" + i;
                        $(spanID).attr('class', 'selectionOFF');
                }

                htmlout = "OBJECTIVES (Click to set)";

                document.getElementById('objectives-display').innerHTML = htmlout;

                $('#ghostNameInput').val("");

                totalObjectives = 0;
		$('#ghostNameInput').focus();

	}

	// Reset all objectives, ghost name and evidence found,
	// then get data using AJAX and show editObjectives panel
	function resetPressed()
	{
		for (var i = 0; i < 3; i++)
		{
			getData[i] = "";
		}

		var objectives = fullData["objectives"];
		for (var i = 0; i < objectives.length; i++)
                {
                        var spanID = "#select" + i;
			$(spanID).attr('class', 'selectionOFF');
                }

                htmlout = "OBJECTIVES (Click to set)";

                document.getElementById('objectives-display').innerHTML = htmlout;

		$('#ghostNameInput').val("");

		totalObjectives = 0;

                //$("#objectives-edit").show(200);
                //$("#objectives-display").hide(200);

		get_data();
		editObjectives();	
	}

	// Remove evidence item from evidence found, sort array and
	// get data using AJAX.
	function deSelectEvidence(item)
	{
		closeEditObjectives();
		for (var i = 0; i < 3; i++)
		{
			if (getData[i] == item)
			{
				getData[i] = "";	
			}
		}
		sortData();
		get_data();
	}

	// Clean up getData array placing all evidence
	// found at array top. There's probably a better
	// way to do this I'm sure!
	function sortData()
	{
		var tempData = new Array(3);
		var pos = 0;
		for (var n = 0; n < 3; n++)
		{
			if ( getData[n] != "" )
			{
				tempData[pos] = getData[n];
				pos++;	
			}
		}
		for (var n = 0; n < 3; n++)
		{
			if ( tempData[n] != "" )
			{
				getData[n] = tempData[n];
			}
			else
			{
				getData[n] = "";
			}
		}
	}

	// Update the whole page, populating the following panels:
	//	Select Evidence
	//	Found Evidence
	//	Found Ghosts
	function displayPage()
	{
		// Logging full data to console for dev purposes,
		// You can safely cooment this out if it bothers you.
		console.log(fullData);
		
		
		populateFoundGhosts( );
		populateFoundEvidence( );
		populateSelectEvidence( );
		if (firstLoad)
		{
			populateObjectives();
			firstLoad = 0;
		}
	}

	// Populate the select Evidence panel.
        function populateSelectEvidence()
        {
		var evidence = fullData["itemsLeft"];
		var totalFound = fullData["totalItemsFound"];
                var eSelect = "";
                for (var i=0; i < evidence.length; i++)
                {
                                eSelect +=  "<span class='e-select' onClick='selectEvidence(\"" + evidence[i]["item_code"] +
 "\");' > ";
                                eSelect += "<img class='s-image' src='images/" + evidence[i]["item_picture"] + "' >";
                                eSelect += "</span>";
                }

                if ( eSelect == "" || totalFound >= 3)
                {
                        eSelect = "DONE";
                        $('#select-evidences').hide(500);
                }
                else if (eSelect == "" || totalFound ==0) 
		{
			eSelect +='<div class="show-all-ghosts-button-container"><span class="ok-button-blue" onClick="showAllGhosts();">Toggle Ghosts Info</div>';
                        $('#select-evidences').show(200);
		}
		else
                {
			eSelect +="<div></div>";
                        $('#select-evidences').show(200);
                }

                document.getElementById('select-evidence').innerHTML = eSelect;
        }


	// Populate the Found Evidence panel.
	function populateFoundEvidence()
        {
		var evidence = fullData["itemsFound"];
		var totalFound = fullData["totalItemsFound"]

                var eSelect = "";
                for (var i=0; i < evidence.length; i++)
                {
                        if ( evidence[i] != "" )
                        {
                                eSelect +=  "<span class='e-select-small' onClick='deSelectEvidence(\"" + evidence[i]["item_code"] + "\");' > ";
                                eSelect += "<img class='s-image-small' src='images/" + evidence[i]["item_picture"] + "' >";
                                eSelect += "</span>";
                        }
                }

                if ( eSelect == "" )
                {
                        eSelect = "NONE";
			$('#found-evidences').hide(500);
                }
                else
                {
                        $('#found-evidences').show(200);
                }

                document.getElementById('found-evidence').innerHTML = eSelect;
        }


	// Populate the Found Ghosts panel
        function populateFoundGhosts(ghosts, totalFound)
        {	
		var ghosts = fullData["ghosts"];
		var totalFound = fullData["totalItemsFound"];
		var eSelect = "";
                for (var i=0; i < ghosts.length; i++)
                {
                        if ( ghosts[i][5] != 0 )
                        {
                                if ( totalFound == 3 )
                                {
                                        eSelect +=  "<span class='g-found' > ";
                                	eSelect += ghosts[i]["ghost_name"].toUpperCase();
                                }
                                else
                                {
                                        eSelect +=  "<span class='g-show'  > ";
                                	eSelect += ghosts[i]["ghost_name"];
                                }
				eSelect += "<div class='evidence-left'>";
				for (var n = 0; n <  ghosts[i]["itemsRequired"].length; n++)
				{
					eSelect += "<span class='tiny-image-container'>";
					eSelect += "<img class='tiny-image' src='images/" + ghosts[i]["itemsRequired"][n]["item_picture"] + "'>";
					eSelect += "<span>";
				}
				eSelect += "</div>";
                                eSelect += "</span>";

                                if (totalFound == 3)
                                {
                                        eSelect += '<div class="ghostInfo" >' + ghosts[i]["ghost_info"] + '</div>';
                                }
                        }
                }

		if ( totalFound > 0 && totalFound < 3)
                {
                        eSelect += '<br><br>';
			document.title = 'Phasmo Helper';
                }

		if (totalFound == 3)
		{
			document.title = ghosts[0]["ghost_name"] + " - Phasmo Helper";
		
		}

                if ( totalFound == 0 )
                {
                        eSelect = "NONE";
                        $("#found-ghosts-list").hide(500);
                        $("#found-ghosts-info-list").hide(500);
			document.title = 'Phasmo Helper';
                }
                else
                {
                        $('#found-ghosts-list').show(200);
                        //$('#found-ghosts-info-list').show(200);
			if (totalFound < 3)
			{
                        	$('#found-ghosts-info-list').show(200);
			}
			else
			{
                        	$('#found-ghosts-info-list').hide(200);

			}
                }
                document.getElementById('found-ghost').innerHTML = eSelect;
		
		var htmlout = "";

		for (var n = 0; n < ghosts.length; n++)
		{
			htmlout += '<div class="info-text">';
			htmlout += '<div class="ghosts-info-header">' + ghosts[n]["ghost_name"] + '</div>';
			htmlout += '<div>' + ghosts[n]["ghost_info"]  + '</div>';
			htmlout += '<div class="ghosts-info-items">' + ghosts[n]["items"]  + '</div>';
			htmlout += '</div>';
		}
                document.getElementById('found-ghost-info').innerHTML = htmlout;
        }

	
	// Populate and show the Show all ghosts panel.
	function showAllGhosts()
	{
		var ghosts = fullData["allGhosts"];
		var htmlout = "";
		for (var n = 0; n < ghosts.length; n++)
		{
			htmlout += '<div class="info-text">';
			htmlout += '<div class="ghosts-info-header">' + ghosts[n]["ghost_name"] + '</div>';
			htmlout += '<div>' + ghosts[n]["ghost_info"]  + '</div>';
			htmlout += '<div class="ghosts-info-items">' + ghosts[n]["items"]  + '</div>';
			htmlout += '</div>';
		}

                document.getElementById('found-ghost-info').innerHTML = htmlout;
		$('#found-ghosts-info-list').toggle(200);	
	}


	//wipe and hide the Show all ghosts panel.
	function hideAllGhosts()
	{
                document.getElementById('found-ghost-info').innerHTML = "";
		$('#found-ghosts-info-list').hide(200);	
	}


	// Populate the objectives panel.
	function populateObjectives()
	{
		var objectives = fullData["objectives"];
		var htmlout = "";
		for (var i = 0; i < objectives.length; i++)
		{
		
			htmlout += '<span class="selectionOFF" id="select' + i  + '"  onClick="toggleSelection(' +i + ');" >';
                        htmlout += objectives[i]["item_code"];
                        htmlout += '</span>';
		}
		document.getElementById('objectives-edit-list').innerHTML = htmlout;
	}


	// Toggle the evidence selection button
	function toggleSelection(selectionID)
	{
		var spanID = "#select" + selectionID;
		var classType =  $(spanID).attr('class') ;
		if (classType == "selectionOFF")
		{
			if (totalObjectives < 3)
			{
				$(spanID).attr('class', 'selectionON');	
				totalObjectives++;
			}
		}
		else
		{
			$(spanID).attr('class', 'selectionOFF');	
			totalObjectives--;
		}
	}


	// Show the Edit Objectives panel.
	function editObjectives()
	{
		$("#objectives-edit").show(200);
		$("#objectives-display").hide(200);
		$('#ghostNameInput').focus();
	}


	// Update objectives mini panel and hide Edit Objectives panel.
	function closeEditObjectives()
	{
		var objectives = fullData["objectives"];

		var htmlout = ""

		//var ghostNameInput = $('#ghostNameInput').val().charAt(0).toUpperCase() + $('#ghostNameInput').val().slice(1);
		var ghostNameInput = $('#ghostNameInput').val().replace(/\b\w/g, l => l.toUpperCase());
		if (ghostNameInput != "")
		{
			htmlout = "<span class='ghostnamesmall'>" + ghostNameInput + "</span>";
		}


		var total = 0		
		for (var i = 0; i < objectives.length; i++)
		{
			var spanID = "#select" + i;
			var classType =  $(spanID).attr('class') ;
			if (classType == "selectionON")
			{
				htmlout += "<span class='objectivesmall'>" + objectives[i]["item_code"] + "</span>";
				total++;
			}
		}
		
		if (total == 0 && ghostNameInput == "")
		{
			htmlout = "OBJECTIVES (Click to set)";
		}
		

		document.getElementById('objectives-display').innerHTML = htmlout;

		$("#objectives-edit").hide(200);
		$("#objectives-display").show(200);
	}

	// APPLICATION INITIALISE!
	// Get data via AJAX and then show the edit objectives panel
	get_data();
	editObjectives();
</script>
