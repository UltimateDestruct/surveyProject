<?php

    //We're sending and receivng JSON with this PHP file
    header('Content-Type: application/json');
    
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
    $infoType = htmlspecialchars($_GET["info"]);
    $surveyid = htmlspecialchars($_GET["surveyid"]);
    $employeeid = htmlspecialchars($_GET["employeeid"]);
    $accessCode = htmlspecialchars($_GET["accessCode"]);
    $departmentid = htmlspecialchars($_GET["departmentid"]);

    //Based on the GET input, choose which MySQL query to run
    switch ($infoType) {
        case 'surveyList':
            $query = "SELECT surveyid, surveyName, `isClosed` FROM survey WHERE deleted = 0";
            break;
        case 'questionList':
            $query = "SELECT question.questionid, question.questionText, question.required
                FROM question
                JOIN employeesurvey USING(surveyid)
                JOIN employee USING(employeeid)
                WHERE question.surveyid = " . $surveyid . " " .
                "AND employee.employeeid = " . $employeeid . " " .
                "AND (employee.departmentid = question.departmentid OR question.departmentid = 1)
                AND question.deleted = 0";
            break;
        case 'departmentList':
            $query = "SELECT departmentName, departmentid FROM department WHERE deleted = 0";
            break;
        case 'questionsBasedOnSurvey':
            $query = "SELECT questionid, questionText, departmentid FROM question 
            WHERE deleted = 0 AND surveyid = " . $surveyid . " " .
            "AND departmentid = IF(" . $departmentid . " = 1, departmentid," . $departmentid . ")";
            break; 
        case 'employeeList':
            $query = "SELECT employee.employeeid, employee.firstname, employee.lastname, department.departmentName, department.departmentid, employee.emailaddress
                FROM employee
                JOIN department USING (departmentid)
                WHERE employee.deleted = 0";
            break;
        case 'surveyResults':
            $query = "SELECT employee.firstname, employee.lastname, employeesurvey.iscompleted, 
            `f_averageScoreOfSurvey`(" . $surveyid .",employeeid) as score
            FROM employee
            JOIN employeesurvey USING(employeeid)
            WHERE surveyid = " . $surveyid;
            break;
        case 'surveyValidation':
            $query = "SELECT isCompleted FROM employeesurvey WHERE employeeid = $employeeid AND surveyid = $surveyid AND accessCode = $accessCode";
            break;  
    }

    //Run the query and send back the data
    try{
        $sql = mysqli_query($conn, $query);
        $rows = array();
        while($result = mysqli_fetch_assoc($sql)) {
            $rows[] = $result;
        }
        echo json_encode($rows);
    }
    catch(mysqli_sql_exception $e) { 
        echo "MySQLi Error Code: " . $e->getCode() . " Exception Msg: " . $e->getMessage();
        exit();
    }

    $conn->close();
?>