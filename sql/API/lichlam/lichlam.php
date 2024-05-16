<?php

include '../connect.php';


if($_SERVER['REQUEST_METHOD'] === "POST"){
        $ngay = $_POST['ngay'];
    $soluong = $_POST['soluong'];
    $ca = $_POST['ca'];
    $sql = "INSERT INTO calamviec (ngay, ca, soluong) VALUES('$ngay', '$ca', '$soluong')";
    $result = mysqli_query($conn, $sql);
    if($result){

    }else{
        
    }
}elseif($_SERVER['REQUEST_METHOD'] === "GET"){
    $sql = "SELECT ca.id, ca.ngay, ca.ca, ca.soluong, ca.dadangky, 
               GROUP_CONCAT(lichlam.nhanvien SEPARATOR ', ') AS nhanvien,
               GROUP_CONCAT(users.fullname SEPARATOR ', ') AS fullname
        FROM calamviec ca
        LEFT JOIN lichlam ON ca.id = lichlam.idca
        LEFT JOIN users ON lichlam.nhanvien = users.username
        GROUP BY ca.id";

$result = $conn->query($sql);

$data = array();

if ($result->num_rows > 0) {
    // Lặp qua kết quả và thêm vào mảng $data
    while($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
} else {
    $data = [
        ["success" => false],
    ];
    echo json_encode($data);
}

$conn->close();


$sql = "SELECT ca.id, ca.ngay, ca.ca, ca.soluong, ca.dadangky, 
               GROUP_CONCAT(lichlam.nhanvien SEPARATOR ', ') AS nhanvien,
               GROUP_CONCAT(users.fullname SEPARATOR ', ') AS fullname
        FROM calamviec ca
        LEFT JOIN lichlam ON ca.id = lichlam.idca
        LEFT JOIN users ON lichlam.nhanvien = users.username
        GROUP BY ca.id";


}elseif($_SERVER['REQUEST_METHOD'] === "DELETE" && isset($_GET['id'])){
    $id = $_GET['id'];
    $sql = "DELETE FROM calamviec WHERE id = '$id'";
    $sql_1 = "DELETE FROM lichlam WHERE idca = '$id'";
    $result = mysqli_query($conn, $sql);
    $result_1 = mysqli_query($conn, $sql_1);
    if($result && $result_1){

    }else{

    }
}

?>