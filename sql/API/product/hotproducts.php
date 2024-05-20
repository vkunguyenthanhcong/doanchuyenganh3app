<?php

include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === "GET") {
    $sql = "SELECT * FROM products ORDER BY hot ASC LIMIT 5";
    $result = mysqli_query($conn, $sql);
    
    if ($result) {
        $data = array();
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
        echo json_encode($data);
    } else {
        echo json_encode(array("success" => false, "message" => "Không có dữ liệu."));
    }
}

// Đóng kết nối
$conn->close();

?>
