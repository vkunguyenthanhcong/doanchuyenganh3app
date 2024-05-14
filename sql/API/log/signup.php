<?php

include '../connect.php';
if($_SERVER['REQUEST_METHOD'] === 'POST'){
    $username = $_POST['username'];
$password = $_POST['password'];
$fullname = $_POST['fullname'];

$sql = "SELECT * FROM users WHERE username = '$username'";
$result = mysqli_query($conn, $sql);

if (mysqli_num_rows($result) > 0) {

    echo json_encode(array("success" => true, "message" => "userhasnotnull"));

}else{
    $r = mysqli_query($conn, "INSERT INTO users (username, password, fullname) VALUES ('$username', '$password' , '$fullname')");
    if($r){
        echo json_encode(array("success"=> true,"message"=> "success"));
    }else{
        echo json_encode(array("success"=> true,"message"=> "fail"));
    }
}
}

?>