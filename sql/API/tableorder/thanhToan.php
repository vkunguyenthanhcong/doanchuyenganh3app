<?php

include '../connect.php';

// Sử dụng hàm mysqli_real_escape_string để tránh tấn công SQL Injection
$idban = mysqli_real_escape_string($conn, $_POST['idban']);
$idhoadon = mysqli_real_escape_string($conn, $_POST['idhoadon']);
$tongtien = mysqli_real_escape_string($conn, $_POST['tongtien']);
$giovao = mysqli_real_escape_string($conn, $_POST['giovao']);
$nhanvien = mysqli_real_escape_string($conn, $_POST['nhanvien']);

$sql = "UPDATE bill SET idhoadon = '$idhoadon', giora = NOW() WHERE idban = '$idban'";
$result = mysqli_query($conn, $sql);

$sql_1 = "INSERT INTO hoadon (idhoadon, nhanvien, tongtien, giovao, giora, idban) 
          VALUES ('$idhoadon', '$nhanvien', '$tongtien', '$giovao', NOW(), '$idban')";
$result_1 = mysqli_query($conn, $sql_1);

if ($result && $result_1) {
    echo json_encode(array("success" => true));
} else {
    echo json_encode(array("success" => false));
}

?>
