<?php 

include '../connect.php';

if($_SERVER['REQUEST_METHOD'] === 'GET'){
  $username = $_GET['username'];
  $sql = "SELECT * FROM users WHERE username = '$username'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_array($result);
echo json_encode(array("success" => true, "password" => $row["password"]));
}elseif($_SERVER["REQUEST_METHOD"] === "POST"){
  $username = $_POST['username'];
$password = $_POST['password'];

$sql = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
$result = mysqli_query($conn, $sql);
if ($result->num_rows > 0) {
    $row = mysqli_fetch_array(mysqli_query($conn, "SELECT * FROM users WHERE username = '$username'"));
    // output data of each row
    echo json_encode(array("success" => true, "message" => "success", 'fullname'=> $row['fullname']));

  } else {
    echo json_encode(array("success" => false, "message" => "fail"));
  }
}
?>