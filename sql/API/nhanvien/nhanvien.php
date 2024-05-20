<?php

include '../connect.php';
if($_SERVER['REQUEST_METHOD'] === "GET" && isset($_GET['all'])){
    $sql = "SELECT username, fullname, luong FROM users";
$result = mysqli_query($conn, $sql);
if(mysqli_num_rows($result) > 0) {
    $data = array();
    while($row = mysqli_fetch_assoc($result)) {
        $data[] = $row;   
    }
    echo json_encode($data);
}else{
    $data = [
        ["success" => false],
    ];
    echo json_encode($data);
}
}elseif($_SERVER["REQUEST_METHOD"] === "GET" && isset($_GET['username'])){
    setlocale(LC_TIME, 'vi_VN'); // Thiết lập ngôn ngữ thành tiếng Việt

    $currentMonthName = date('m');
    $currentYear = date('Y');
    $username = $_GET['username'];
    $sql = "SELECT * FROM users WHERE username = '$username'";
    $result = mysqli_query($conn, $sql);

    $sql_1 = "SELECT SUM(ll.tongluong) AS tongluong FROM lichlam ll, calamviec ca WHERE ll.nhanvien = '$username' AND MONTH(ca.ngay) = 5 AND YEAR(ca.ngay) = 2024";
    $result_1 = mysqli_query($conn, $sql_1);
    
    if($result){
        $row = mysqli_fetch_assoc($result);
        $row_1 = mysqli_fetch_assoc($result_1);
        echo json_encode(array("success" => true, "fullname" => $row['fullname'], "roll" => $row['roll'], "luong" => $row['luong'], "tongluong" => $row_1['tongluong']));
    }else{
        echo json_encode(array("success" => false, "message" => "fail"));
    }
}


?>