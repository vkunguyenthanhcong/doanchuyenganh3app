<?php

include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $tenloai = $_POST['tenloai'];

    // Sử dụng Prepared Statements để ngăn ngừa SQL Injection
    $stmt = $conn->prepare("INSERT INTO loaisanpham (tenloai) VALUES (?)");
    $stmt->bind_param("s", $tenloai);
    
    if ($stmt->execute()) {
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false, "error" => $stmt->error));
    }
    $stmt->close();

} elseif ($_SERVER["REQUEST_METHOD"] === "DELETE" && isset($_GET['id'])) {
    $id = $_GET['id'];

    // Sử dụng Prepared Statements để ngăn ngừa SQL Injection
    $stmt = $conn->prepare("DELETE FROM loaisanpham WHERE id = ?");
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false, "error" => $stmt->error));
    }
    $stmt->close();
}

// Đóng kết nối
$conn->close();

?>
