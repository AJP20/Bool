<?php
include_once("mysql_connect.php");
?>
<?php

$email = $_REQUEST['Email'];
$password = $_REQUEST['Password'];

$sql = "SELECT count(*) FROM Users WHERE(Email='$email' and  Password='$password')";

$idsql = "SELECT id FROM Users WHERE(Email='$email' and  Password='$password')";

$qury = mysql_query($sql);
$result = mysql_fetch_array($qury);
$idqury = mysql_query($idsql);
$id = mysql_fetch_array($idqury);

if($result[0]>0)
{
	$returnValue = array("email"=>$email, "pof"=>1,"id"=>$id[0]);
  	echo json_encode($returnValue);
}
else
{
  $returnValue = array("email"=>$email, "pof"=>0);
  echo json_encode($returnValue);
}
?>