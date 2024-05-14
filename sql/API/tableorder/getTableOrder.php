<?php

include '../connect.php';

if($_SERVER['REQUEST_METHOD'] === "POST"){
    $ten = $_POST["ten"];
    $sql = "INSERT INTO tableorder (ten) VALUES('$ten')";
    $result = mysqli_query($conn, $sql);
    if($result){
        echo json_encode(array("success" => true));
    }else{
        echo json_encode(array("success" => false));
    }
}elseif($_SERVER['REQUEST_METHOD'] === "GET"){
    $sql = "SELECT * FROM tableorder";
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) > 0){
        $data = array();
        while ($row = mysqli_fetch_assoc($result)) {
            // Parse date to suitable format
            $data[] = $row;
        }
        echo json_encode($data);
    }
    else{
        $data = [
            ["success" => false],
        ];
        echo json_encode($data);
    }
}
?>