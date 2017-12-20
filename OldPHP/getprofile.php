<?php
include_once("mysql_connect.php");
?>
<?php
$id= $_REQUEST["id"];
$user = "SELECT PhoneNumber,Snapchat,Instagram,Twitter FROM Profiles WHERE id='$id'";
$uresult = mysql_query($user);
$i = mysql_fetch_array($uresult);
$pnum = $i['PhoneNumber'];
$snap = $i['Snapchat'];
$insta = $i['Instagram'];
$twit = $i['Twitter'];

if(!$q)
{
	$returnValue = array("phonenumber"=>$pnum,"snapchat"=>$snap,"instagram"=>$insta,"twitter"=>$twit,"pof"=>1);
  	echo json_encode($returnValue);
}
else
{
	$returnValue = array("phonenumber"=>$pnum,"snapchat"=>$snap,"instagram"=>$insta,"twitter"=>$twit,"pof"=>0);
  	echo json_encode($returnValue);
}
?>