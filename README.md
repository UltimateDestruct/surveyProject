# Answers to questions

I'll give the basic summary of each question from the assignment given to me, then I'll answer each question

### Question 1: Design a database application to support a survey
![databaseDiagram](/images/databaseStructure.png)

### Question 2: One week from the deadline the customer asked for a new feature: they want to make the survey an annual event. How do you facilitate that?
If you designed your database correctly then you shouldn't need to make any changes. Customer requests should come with 4 things kept in mind:
1. Avoid feature creep
1. Empower the customer
1. Future-proof your design
1. Automate things as much as possible.

Part 3 of that philosophy means that at the outset of your design you should anticipate things like the customer changing their minds again, and instead of this being an annual survey they want to run multiple surveys at the same time - and they also want yes/no questions in addition to the regular 1 though 5 questions.

In the database I designed the survey and employeesurvey tables make it so that you can handle the customer's request.

### Question 3: Write an SQL query that will display the questions for employeeid 233714 for the current survey
```mysql
SET @employeeid = 233714;
SET @currentSurvey = 1;

SELECT question.questionid, 
question.questionText,
question.surveyid
FROM employeesurvey
JOIN question USING(surveyid)
JOIN department USING(departmentid)
JOIN employee USING(employeeid)
WHERE employeesurvey.employeeid = @employeeid
AND employeesurvey.surveyid = @currentSurvey
#In this database department 1 is for questions for "All" departments
AND question.departmentid IN(1,employee.departmentid);
```

You won't get a result from that query because my employee table doesn't have data for 200,000+ employees currently. I could either write a script that auto-inserts a bunch of rows, or I could change the autoincrement of the table to reach up that high.

### Question 4: Write an SQL query that will display the users who have not completed the current survey.
```mysql
SET @currentSurvey = 1;

SELECT employee.employeeid,
employee.firstname,
employee.lastname
FROM employee
JOIN employeesurvey USING(employeeid)
WHERE employeesurvey.surveyid = @currentSurvey
AND employeesurvey.isCompleted = 0;
```

### Question 5: Describe how you would interact with employee data using PHP
The answer to this question can be found by looking at the 2 PHP files I created: getInfo.php and saveInfo.php. They pretty much just receive a request for data in the form of JSON, query the database, then return info in the form of JSON. The only special thing here is that the first element of the JSON acts as a header for the type of information being requested, and a CASE statement makes sure that the correct information is sent back.

### Question 6: Create methods/functions to save and retrieve survey responses
This is handled by fetch requests from the HTML/Javascript files to the PHP files.

### Question 7: Display the employee satisfaction score (average score of all the employee's answers) per survey
The survey results can be found on the View Results page of the admin tool that I made (index.html).

### Question 8: Create a web form for the survey
This is basically survey.html, but it's a little more complicated than that. The web form for the survey populates based upon parameters in the URL (the 1st question noted that each employee would receive a unique URL). To protect against URL manipulation attacks each survey URL has been given an access code that must be validated before the survey is submitted. This makes it so that Employee1 can't change a value in the URL and complete Employee2's survey.

The survey URLs can be found in the employeesurvey table of the database.

# How to set up the survey project
The survey project runs off of the WAMP stack
* Windows - Windows 10 is recommended, but it should run fine on Windows 7 and 8
* Apache - Apache 2.4.37 was used, but anything later than that should be fine
* MySQL - MySQL 5.6.22 was used, but later versions should be fine
* PHP - PHP 7.0.33 was used, but later versions should be alright

>Note: You may want want to set up a MySQL user called 'test'. Giving them full permissions to the 'survey' database will be an easy way to configure the account, but it shouldn't need more than EXECUTE, INSERT, SELECT, TRIGGER, and UPDATE permissions)

Once the technology stack is set up, download and unzip the files from GitHub. You should have a 'survey' folder in the top layer of your 'www' directory that all the files go into.

After that, run the survey_database_setup.sql file on your MySQL database to set up the database structure.

The configuration file for PHP is called config.php; change the values in that file to reflect the 'test' MySQL account that you created earlier.

From there you're all set! In your web browser visit http://localhost/survey/index.html (assuming you're running the page on the server with Apache pointed to port 80) for the admin panel. The example database comes with the basic structure, but just bare-bones data. You will need to:
1. Add employees to the company
1. Schedule a new survey (which will auto-populate the employeesurvey table with access codes and URLs)
1. Add questions to the newly created survey

>After you've set up a survey using the admin panel you can open up an instance of the survey by adding URL parameters to the end of http://localhost/survey/survey.html. For example, a survey URL may look like this: localhost/survey.html?employeeid=1&surveyid=1&accesscode=12345. The list of valid survey URLs can be found in the employeesurvey table of the database.

# Future feature requests
They say that a piece of art is never finished - it is only abandoned. I find that software is the same way; there are always more features that you CAN add, but you need to figure out what you WILL add and what you WILL NOT add. Here are a few features that I would like to add to the project, but they didn't get included in the current feature list:

* The ability to edit employees/questions/surveys instead of just adding or deleting them
* Other question types (I layed the groundwork for this in the current system, but it needs to be more fleshed out)
* Deparment validation: The access code prevents you from manipulating the URL to submit answers from another user, but if you're clever you can manipulate the URL to view questions from other departments. This was not considered enough of a security risk to make it into the current version of the software.
* Include comments in the View Results page of the admin panel - The optional comments are saved in the database, but the assignment seemed more focused on generating an average employee satisfaction score than it was about displaying the comments. My leading design idea is to have an accordion-style button next to the customer score where you click the button and the comments appear underneath the row you selected.
