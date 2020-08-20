/*
SQLyog Community v12.2.5 (64 bit)
MySQL - 5.6.22-log : Database - survey
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`survey` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `survey`;

/*Table structure for table `answer` */

DROP TABLE IF EXISTS `answer`;

CREATE TABLE `answer` (
  `answerid` int(10) NOT NULL AUTO_INCREMENT,
  `employeeid` int(10) NOT NULL,
  `questionid` int(10) NOT NULL,
  `result` int(10) NOT NULL,
  PRIMARY KEY (`answerid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `answer` */

/*Table structure for table `comment` */

DROP TABLE IF EXISTS `comment`;

CREATE TABLE `comment` (
  `commentid` int(10) NOT NULL AUTO_INCREMENT,
  `surveyid` int(10) NOT NULL,
  `employeeid` int(10) NOT NULL,
  `commentText` text,
  PRIMARY KEY (`commentid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `comment` */

/*Table structure for table `department` */

DROP TABLE IF EXISTS `department`;

CREATE TABLE `department` (
  `departmentid` int(10) NOT NULL AUTO_INCREMENT,
  `departmentName` varchar(50) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Whether or not this department still exists in the company',
  PRIMARY KEY (`departmentid`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

/*Data for the table `department` */

insert  into `department`(`departmentid`,`departmentName`,`deleted`) values 
(1,'All',0),
(2,'Marketing',0),
(3,'Management',0),
(4,'HR',0),
(5,'Tech Support',0),
(6,'Development',0),
(7,'Sales',0);

/*Table structure for table `employee` */

DROP TABLE IF EXISTS `employee`;

CREATE TABLE `employee` (
  `employeeid` int(10) NOT NULL AUTO_INCREMENT,
  `firstName` varchar(25) NOT NULL,
  `lastName` varchar(25) NOT NULL,
  `departmentid` int(10) NOT NULL,
  `deleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Whether or not the user is an active employee',
  `emailaddress` varchar(50) NOT NULL,
  PRIMARY KEY (`employeeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `employee` */

/*Table structure for table `employeesurvey` */

DROP TABLE IF EXISTS `employeesurvey`;

CREATE TABLE `employeesurvey` (
  `employeeSurveyid` int(10) NOT NULL AUTO_INCREMENT,
  `employeeid` int(10) NOT NULL,
  `surveyid` int(10) NOT NULL,
  `isCompleted` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Has the employee completed the survey?',
  `accessCode` int(10) NOT NULL,
  `surveyurl` text,
  PRIMARY KEY (`employeeSurveyid`),
  KEY `employee` (`employeeid`),
  KEY `survey` (`surveyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `employeesurvey` */

/*Table structure for table `question` */

DROP TABLE IF EXISTS `question`;

CREATE TABLE `question` (
  `questionid` int(10) NOT NULL AUTO_INCREMENT,
  `questionText` varchar(100) NOT NULL COMMENT 'The text of the question that is being asked',
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  `questionTypeid` int(10) NOT NULL,
  `departmentid` int(10) NOT NULL,
  `surveyid` int(10) NOT NULL,
  `required` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`questionid`),
  KEY `questionType` (`questionTypeid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `question` */

/*Table structure for table `questiontype` */

DROP TABLE IF EXISTS `questiontype`;

CREATE TABLE `questiontype` (
  `questionTypeid` int(10) NOT NULL AUTO_INCREMENT,
  `questionTypeName` varchar(25) NOT NULL COMMENT 'The title of the question type (ex: trueOrFalse)',
  PRIMARY KEY (`questionTypeid`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

/*Data for the table `questiontype` */

insert  into `questiontype`(`questionTypeid`,`questionTypeName`) values 
(1,'1to5');

/*Table structure for table `survey` */

DROP TABLE IF EXISTS `survey`;

CREATE TABLE `survey` (
  `surveyid` int(10) NOT NULL AUTO_INCREMENT,
  `surveyName` varchar(50) NOT NULL,
  `isClosed` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is the survey closed for responses?',
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`surveyid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Data for the table `survey` */

/* Trigger structure for table `survey` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `t_populate_employeesurvey` */$$

/*!50003 CREATE */ /*!50003 TRIGGER `t_populate_employeesurvey` AFTER INSERT ON `survey` FOR EACH ROW call `p_populate_employeesurvey`() */$$


DELIMITER ;

/* Function  structure for function  `f_averageScoreOfSurvey` */

/*!50003 DROP FUNCTION IF EXISTS `f_averageScoreOfSurvey` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `f_averageScoreOfSurvey`(surveyNumber int, employeeNumber int ) RETURNS decimal(10,2)
    DETERMINISTIC
BEGIN
	DECLARE result DECIMAL (10,2);
	
	SELECT AVG(answer.result)
	FROM answer
	JOIN question USING(questionid)
	WHERE surveyid = surveyNumber
	AND employeeid = employeeNumber into result;
	
	return result;
END */$$
DELIMITER ;

/* Function  structure for function  `f_checkAccessCode` */

/*!50003 DROP FUNCTION IF EXISTS `f_checkAccessCode` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `f_checkAccessCode`(employeeNumber INT, surveyNumber int, accessCode int) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN
	
	#If a match is found with the employeeid, surveyid, and access code then return True, otherwise return False
	RETURN (SELECT IF((SELECT accessCode 
	FROM `employeesurvey`
	WHERE employeeid = 1
	AND surveyid = 1
	AND accesscode = 1245) IS NULL,'False','True'));
	
END */$$
DELIMITER ;

/* Function  structure for function  `f_generateAccessCode` */

/*!50003 DROP FUNCTION IF EXISTS `f_generateAccessCode` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `f_generateAccessCode`(seed int) RETURNS int(10)
    DETERMINISTIC
BEGIN
	
#Generate a random 5-digit access code
return (SELECT FLOOR(RAND(seed)*100000)  AS accessCode);
	
END */$$
DELIMITER ;

/* Function  structure for function  `f_generateurl` */

/*!50003 DROP FUNCTION IF EXISTS `f_generateurl` */;
DELIMITER $$

/*!50003 CREATE FUNCTION `f_generateurl`(employeeid INT, surveyid int, accesscode int) RETURNS text CHARSET utf8
    DETERMINISTIC
BEGIN
	
return (SELECT CONCAT("localhost/survey/survey.html?employeeid=",employeeid,"&surveyid=",surveyid,"&accesscode=",accesscode));
	
END */$$
DELIMITER ;

/* Procedure structure for procedure `p_populate_employeesurvey` */

/*!50003 DROP PROCEDURE IF EXISTS  `p_populate_employeesurvey` */;

DELIMITER $$

/*!50003 CREATE PROCEDURE `p_populate_employeesurvey`()
begin
DECLARE surveyNumber, employeeNumber, accessCodeNumber INT;
DECLARE surveyurlText text;
SET surveyNumber = (select max(surveyid) from survey);
set surveyurlText = (select `f_generateurl`(employeeNumber, surveyNumber, accessCodeNumber));
#Create new rows for the new survey
insert into employeesurvey (employeeid, surveyid, isCompleted, accessCode)
(SELECT 
employeeid, 
surveyNumber AS surveyid, 
0 AS isCompleted, 
(SELECT `f_generateAccessCode`(employeeid)) AS accessCode
FROM employee
where employee.deleted = 0);
#Populate the URLs
UPDATE `employeesurvey` SET surveyurl = 
(SELECT `f_generateurl`(employeeid,surveyNumber,accessCode))
WHERE surveyid = surveyNumber;
end */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
