<?php
$conn = mysql_connect('localhost:3306','anphamut_admin','ajp20k97');
$db   = mysql_select_db('anphamut_eTact',$conn);
if (!$db) {
	die('Could not connect: '.mysql_error());
}
?>