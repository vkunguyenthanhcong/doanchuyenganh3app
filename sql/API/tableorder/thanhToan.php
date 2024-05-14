<?php

include '../connect.php';
$idban = $_POST['idban'];
$idhoadon = $_POST['idhoadon'];
$tongtien = $_POST['tongtien'];
$giovao = $_POST['giovao'];
$nhanvien = $_POST['nhanvien'];
$sql = "UPDATE bill SET idhoadon = '$idhoadon' , giora = now() WHERE idban = '$idban'";
$result = mysqli_query($conn, $sql);
$sql_1 = "INSERT INTO hoadon (idhoadon, nhanvien, tongtien, giovao, giora, idban) VALUES ('$idhoadon', '$nhanvien', '$tongtien', '$giovao', now(), '$idban')";
$result_1 = mysqli_query($conn, $sql_1);
if($result && $result_1){
    echo json_encode(array("success" => true));
}else{
    echo json_encode(array("success" => false));
}



?>