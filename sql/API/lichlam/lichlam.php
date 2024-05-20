<?php

include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === "POST") {
    if (isset($_POST['ngay']) && isset($_POST['soluong']) && isset($_POST['ca'])) {
        $ngay = $_POST['ngay'];
        $soluong = $_POST['soluong'];
        $ca = $_POST['ca'];

        // Sử dụng prepared statement để chèn dữ liệu vào calamviec
        $stmt = $conn->prepare("INSERT INTO calamviec (ngay, ca, soluong) VALUES (?, ?, ?)");
        $stmt->bind_param("ssi", $ngay, $ca, $soluong);
        if ($stmt->execute()) {
            echo json_encode(array("success" => true));
        } else {
            echo json_encode(array("success" => false, "message" => "Error inserting data"));
        }

        // Đóng statement
        $stmt->close();
    } else {
        echo json_encode(array("success" => false, "message" => "Invalid input"));
    }
} elseif ($_SERVER['REQUEST_METHOD'] === "GET") {
    $sql = "SELECT ca.id, ca.ngay, ca.ca, ca.soluong, ca.dadangky, 
               GROUP_CONCAT(lichlam.nhanvien SEPARATOR ', ') AS nhanvien,
               GROUP_CONCAT(users.fullname SEPARATOR ', ') AS fullname
            FROM calamviec ca
            LEFT JOIN lichlam ON ca.id = lichlam.idca
            LEFT JOIN users ON lichlam.nhanvien = users.username
            GROUP BY ca.id";
    
    $result = $conn->query($sql);

    $data = array();

    if ($result) {
        if ($result->num_rows > 0) {
            // Lặp qua kết quả và thêm vào mảng $data
            while ($row = $result->fetch_assoc()) {
                $data[] = $row;
            }
            echo json_encode($data, JSON_UNESCAPED_UNICODE);
        } else {
            echo json_encode(array("success" => false, "message" => "No records found"));
        }
    } else {
        echo json_encode(array("success" => false, "message" => "Error executing query"));
    }
} elseif ($_SERVER['REQUEST_METHOD'] === "DELETE" && isset($_GET['id'])) {
    $id = $_GET['id'];

    // Sử dụng prepared statements để xóa dữ liệu
    $stmt = $conn->prepare("DELETE FROM calamviec WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt_1 = $conn->prepare("DELETE FROM lichlam WHERE idca = ?");
    $stmt_1->bind_param("i", $id);

    if ($stmt->execute() && $stmt_1->execute()) {
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false, "message" => "Error deleting data"));
    }

    // Đóng statements
    $stmt->close();
    $stmt_1->close();
}

// Đóng kết nối
$conn->close();
?>
