var localIP="http://123.123.123.123";



function XMLData(){
	let request = new XMLHttpRequest();
	request.open("GET", localIP+":8080/DynamicWebPage/get-data?format=xml", true);
	request.send();
	request.onreadystatechange = function(){
            if(request.readyState == 4 && request.status == 200){
                let data = request.responseXML;
                let payload = data.getElementsByTagName('person');
                let tableString = "<table border=\"1\"><tr><td>Name</td><td>Age</td><td>Home</td></tr>";
                for(let i = 0; i < payload.length; i++){
                        tableString += "<tr><td>" + payload[i].childNodes[0].innerHTML + "</td><td>" + payload[i].childNodes[1].innerHTML + "</td><td>" + payload[i].childNodes[2].innerHTML + "</td></tr>";
                }
                tableString += "</table>";
                document.getElementById('xmlOutput').innerHTML = tableString;
            }
	}
}//end testString()


function jsonData(){
	let request = new XMLHttpRequest();
	request.open("GET", localIP+":8080/DynamicWebPage/get-data?format=json", true);
	request.send();
	request.onreadystatechange = function(){
            if(request.readyState == 4 && request.status == 200){
                let payload = JSON.parse(request.responseText);
                let tableString = "<table border=\"1\"><tr><td>Name</td><td>Age</td><td>Home</td></tr>";
                for(let i = 0; i < payload['people'].length; i++){
                    tableString += "<tr><td>" + payload['people'][i]['name'] + "</td><td>" + payload['people'][i]['age'] + "</td><td>" + payload['people'][i]['home'] + "</td></tr>";
                }
                tableString += "</table>";
                document.getElementById('jsonOutput').innerHTML = tableString;
            }
	}
}//end testString()

