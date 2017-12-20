<?php
include_once("mysql_connect.php");
?>
<?php
// Read request parameters
$phoneNum= $_REQUEST["PhoneNumber"];
$snap = $_REQUEST["Snapchat"];
$insta = $_REQUEST["Instagram"];
$twit = $_REQUEST["Twitter"];
$id = $_REQUEST["id"];
$sql = "UPDATE Profiles SET PhoneNumber='$phoneNum',Snapchat='$snap',Instagram='$insta',Twitter='$twit' WHERE id='$id'";
$qury = mysql_query($sql);
if(!$qury)
{
	$returnValue = array("id"=>$id, "pof"=>0);
  	echo json_encode($returnValue);
}
else
{
	$returnValue = array("id"=>$id, "pof"=>1);
  	echo json_encode($returnValue);
}
?>