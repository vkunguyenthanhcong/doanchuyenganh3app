<?php

include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === "GET") {
    // Sử dụng Prepared Statements để ngăn chặn SQL injection
    $stmt = $conn->prepare("SELECT * FROM loaisanpham");
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $data = array();
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode($data);
    } else {
        echo json_encode(array("message" => "Không có dữ liệu."));
    }
    $stmt->close();
}

// Đóng kết nối
$conn->close();

?>
