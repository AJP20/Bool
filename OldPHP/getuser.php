<?php
include_once("mysql_connect.php");
?>
<?php
$device= $_REQUEST["Device"];
$user = "SELECT FirstName,LastName,id FROM Users WHERE Device='$device'";
$uresult = mysql_query($user);
$i = mysql_fetch_array($uresult);
$fname = $i['FirstName'];
$lname = $i['LastName'];
$id = $i['id'];

if(!$q)
{
	$returnValue = array("firstname"=>$fname,"lastname"=>$lname,"id"=>$id,"pof"=>1);
  	echo json_encode($returnValue);
}
else
{
	$returnValue = array("firstname"=>$fname,"lastname"=>$lname,"id"=>$id,"pof"=>0);
  	echo json_encode($returnValue);
}
?>