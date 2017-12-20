<?php
include_once("mysql_connect.php");
?>
<?php
// Read request parameters
$firstName= $_REQUEST["FirstName"];
$lastName = $_REQUEST["LastName"];
$email = $_REQUEST["Email"];
$password = $_REQUEST["Password"];

$phoneNum = $_REQUEST["PhoneNumber"];
$snap = $_REQUEST["Snapchat"];
$insta = $_REQUEST["Instagram"];
$twit = $_REQUEST["Twitter"];

$device = $_REQUEST["Device"];

$usersql = "INSERT INTO Users (FirstName,LastName,Email,Password,Device) VALUES('$firstName','$lastName','$email','$password','$device')";

$userqury = mysql_query($usersql);

$profsql = "INSERT INTO Profiles (PhoneNumber, Snapchat, Instagram, Twitter, id) VALUES ('$phoneNum','$snap','$insta','$twit',(SELECT id FROM Users WHERE(Email='$email' and  Password='$password')))";

$profqury = mysql_query($profsql);

if(!$userqury || !$profqury)
{
	$returnValue = array("email"=>$email, "pof"=>0);
  	echo json_encode($returnValue);
}
else
{
	$returnValue = array("email"=>$email, "pof"=>1);
  	echo json_encode($returnValue);
}
?>