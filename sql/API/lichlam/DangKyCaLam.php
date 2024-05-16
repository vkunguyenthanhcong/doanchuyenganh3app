<?php 

include '../connect.php';
if($_SERVER['REQUEST_METHOD'] === "POST"){
    $idca = $_POST["idca"];
    $nhanvien = $_POST['username'];
    $sql = "SELECT soluong FROM calamviec WHERE id = '$idca'";
    $result = mysqli_query($conn, $sql);
    $row = mysqli_fetch_array($result);

    $sql_1 = "SELECT * FROM lichlam WHERE idca = '$idca'";
    $result_1 = mysqli_query($conn, $sql_1);

    if(mysqli_num_rows($result_1) >= $row['soluong']){
        echo json_encode(array("success" => false));
    }else{
        $sql_2 = "INSERT INTO lichlam (nhanvien, idca) VALUES ('$nhanvien', '$idca')";
        $result_2 = mysqli_query($conn, $sql_2);
        if($result_2){
            echo json_encode(array("success" => true));
        }else{
        }
    }
}

?>