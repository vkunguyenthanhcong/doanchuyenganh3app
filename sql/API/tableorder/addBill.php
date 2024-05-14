<?php

include '../connect.php';

if($_SERVER['REQUEST_METHOD'] === "POST"){
    $idban = $_POST["idban"];
    $idmon = $_POST["idmon"];
    $sql = "INSERT INTO bill (idban, idmon, giovao, soluong) VALUES ('$idban', '$idmon', now(), 1)";
    
    $result = mysqli_query($conn, $sql);
    
    if($result){
        $sql_1 = "SELECT SUM(b.soluong) AS soluong, SUM(pr.gia) AS tongtien FROM bill b, products pr WHERE b.idban = '$idban' AND pr.id = b.idmon";
        $result_1 = mysqli_query($conn, $sql_1);
        $row = mysqli_fetch_array($result_1);    
        echo json_encode(array("success" => true, "tongtien" => $row["tongtien"], "soluong" => $row['soluong']));
    }else{
        echo json_encode(array("success" => false));
    }
}elseif($_SERVER['REQUEST_METHOD'] === "GET" && isset($_GET["id"])){
    $idban = $_GET["id"];
    $sql = "SELECT SUM(b.soluong) AS soluong, SUM(pr.gia) AS tongtien FROM bill b, products pr WHERE b.idban = '$idban' AND pr.id = b.idmon";
    $result = mysqli_query($conn, $sql);
    if($result){
        $row = mysqli_fetch_array($result);    
        echo json_encode(array("success" => true, "tongtien" => $row["tongtien"], "soluong" => $row['soluong']));
    }else{
        echo json_encode(array("success" => false));
    }
}


?>