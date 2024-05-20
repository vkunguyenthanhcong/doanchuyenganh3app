<?php 

include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === "POST") {
    if (isset($_POST['idca']) && isset($_POST['username'])) {
        $idca = $_POST['idca'];
        $nhanvien = $_POST['username'];

        // Sử dụng prepared statement để lấy soluong từ calamviec
        $stmt = $conn->prepare("SELECT soluong FROM calamviec WHERE id = ?");
        $stmt->bind_param("i", $idca);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $soluong = $row['soluong'];

            // Sử dụng prepared statement để đếm số lượng lịch làm việc đã đăng ký
            $stmt = $conn->prepare("SELECT COUNT(*) AS count FROM lichlam WHERE idca = ?");
            $stmt->bind_param("i", $idca);
            $stmt->execute();
            $result = $stmt->get_result();
            $row = $result->fetch_assoc();
            $count = $row['count'];

            if ($count >= $soluong) {
                echo json_encode(array("success" => false, "message" => "Shift is full"));
            } else {
                // Sử dụng prepared statement để chèn dữ liệu vào lichlam
                $stmt = $conn->prepare("INSERT INTO lichlam (nhanvien, idca) VALUES (?, ?)");
                $stmt->bind_param("si", $nhanvien, $idca);
                if ($stmt->execute()) {
                    echo json_encode(array("success" => true));
                } else {
                    echo json_encode(array("success" => false, "message" => "Error inserting data"));
                }
            }
        } else {
            echo json_encode(array("success" => false, "message" => "Invalid shift ID"));
        }

        // Đóng statement
        $stmt->close();
    } else {
        echo json_encode(array("success" => false, "message" => "Invalid input"));
    }
}

// Đóng kết nối
$conn->close();
?>
