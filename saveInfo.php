<?php

  //We're sending and receivng JSON with this PHP file
  header('Content-Type: application/json');

  $json = file_get_contents('php://input');
  $data = json_decode($json,true);

  //Import the database credentials
  require_once 'config.php';

  //MySQL Connection
  $servername = DB_HOST;
  $username = DB_USER;
  $password = DB_PASSWORD;
  $database = DB_NAME;

  $conn = new mysqli($servername, $username, $password, $database);

  if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
  }

  /*Possible parameters passed to the server, only the relavent ones will be filled out per
  request, and all others will be ignored during the request*/
  $infoType = $data['infoType'];
  	if(isset($data['surveyTitle'])){
	  $surveyTitle = $data['surveyTitle'];
	}
	if(isset($data['startDate'])){
  		$startDate = $data['startDate'];
	}
	if(isset($data['endDate'])){
  $endDate = $data['endDate'];
	}
	if(isset($data['firstName'])){
  $firstName = $data['firstName'];
	}
	if(isset($data['lastName'])){
  $lastName = $data['lastName'];
	}
	if(isset($data['departmentid'])){
  $departmentid = $data['departmentid'];
	}
	if(isset($data['questionText'])){
  $questionText = $data['questionText'];
	}
	if(isset($data['questionTypeid'])){
  $questionTypeid = $data['questionTypeid'];
	}
	if(isset($data['surveyid'])){
  $surveyid = $data['surveyid'];
	}
	if(isset($data['requiredQuestion'])){
  $requiredQuestion = $data['requiredQuestion'];
	}
	if(isset($data['questionid'])){
  $questionid = $data['questionid'];
	}
	if(isset($data['employeeid'])){
  $employeeid = $data['employeeid'];
	}
	if(isset($data['answerList'])){
  $answerList = $data['answerList'];
	}
	if(isset($data['accessCode'])){
  $accessCode = $data['accessCode'];
	}
	if(isset($data['emailAddress'])){
  $emailAddress = $data['emailAddress'];
	}
	if(isset($data['commentText'])){
		$commentText = $data['commentText'];
	}

  //Based on the POST input, choose which MySQL query to run
  switch ($infoType) {
      case 'saveNewSurveySchedule':
          $query = "INSERT INTO survey (surveyName, `isClosed`) 
          VALUES('" . $surveyTitle . "',0)";
          $message = "New record created successfully";
          break;
      case 'saveNewEmployee':
          $query = "INSERT INTO employee (firstName, lastName, departmentid, emailaddress) 
          VALUES('" . $firstName . "','" . $lastName . "'," . $departmentid . ",'" . $emailAddress . "')";
          $message = "New record created successfully";
          break;
      case 'saveNewQuestion':
          $query = "INSERT INTO question (questionText, questionTypeid, departmentid, surveyid, `required`) 
          VALUES('" . $questionText . "'," . $questionTypeid . "," . $departmentid . "," .
          $surveyid . "," . $requiredQuestion . ")";
          $message = "New record created successfully";
          break;
      case 'deleteSurveySchedule':
          $query = "UPDATE survey SET deleted = 1 WHERE surveyid = " . $surveyid;
          $message = "Record deleted successfully";
          break;
      case 'deleteQuestion':
          $query = "UPDATE question SET deleted = 1 WHERE questionid = " . $questionid;
          $message = "Record deleted successfully";
          break;
      case 'deleteEmployee':
          $query = "UPDATE employee SET deleted = 1 WHERE employeeid = " . $employeeid;
          $message = "Record deleted successfully";
          break;
      case 'surveySubmission':
          //Build the start of the query
          $query = "INSERT INTO answer(employeeid,questionid,result) VALUES ";
          //Populate the query with a new row of values
          for($i=0;$i<count($answerList);$i++){
            $query = $query . "(" . $employeeid ."," . $answerList[$i]['questionid'] . "," . $answerList[$i]['answer'] . ")";
            //Don't include a comma after the last line
            if($i != count($answerList)-1){
              $query = $query . ",";
            }
          }
          $message = "Answers submitted!";
          break;
		case 'commentSubmission':
			//If the comment text is not set, set it to empty string
			if(!$commentText){
				$commentText = '';
			}
			$query = "INSERT INTO `comment` (surveyid, employeeid, commentText) VALUES(" . $surveyid . "," . $employeeid . ",'" . $commentText . "')";
			$message = 'Comments submitted!';
          	break;
		case 'completeEmployeeSurvey':
          $query = "UPDATE employeeSurvey SET isCompleted = 1 WHERE employeeid = " . $employeeid . " AND surveyid = " . $surveyid;
          $message = "Employee survey marked as completed!";
          break;  
  }

  //Run the query and send back a message
  
  if ($conn->query($query) === TRUE) {
	  echo json_encode($message);
    } 
      else{
        echo json_encode("Query Error");
    } 

  $conn->close();

?>