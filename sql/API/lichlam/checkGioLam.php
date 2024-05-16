<?php
// Kết nối đến cơ sở dữ liệu
include '../connect.php';
$nhanvien = $_GET['username'];
$target_time = $_GET['timenow'];

$sql = "SELECT ca.ca, ll.tinhtrang FROM calamviec ca, lichlam ll WHERE ca.id = ll.idca AND ll.nhanvien ='$nhanvien' ORDER BY ABS(TIME_TO_SEC(TIMEDIFF(STR_TO_DATE(ca, '%H:%i'), STR_TO_DATE('$target_time', '%H:%i')))) ASC
LIMIT 1";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    // Lấy dữ liệu từ kết quả truy vấn
    $row = $result->fetch_assoc();
    $nearest_time = $row['ca'];
    $tinhtrang  = $row['tinhtrang'];
    echo json_encode(array("success" => true, "time" => $nearest_time, "tinhtrang" => $tinhtrang));
} else {
    echo json_encode(array("success" => false));
}

$conn->close();
?>
