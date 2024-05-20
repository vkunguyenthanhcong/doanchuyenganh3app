<?php

include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Kiểm tra các biến POST
    if (isset($_POST['username']) && isset($_POST['password']) && isset($_POST['fullname'])) {
        $username = $_POST['username'];
        $password = $_POST['password'];
        $fullname = $_POST['fullname'];

        // Sử dụng prepared statement để kiểm tra username tồn tại
        $stmt = $conn->prepare("SELECT 1 FROM users WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $stmt->store_result();

        if ($stmt->num_rows > 0) {
            echo json_encode(array("success" => true, "message" => "userhasnotnull"));
        } else {
            // Sử dụng prepared statement để chèn dữ liệu người dùng mới
            $stmt = $conn->prepare("INSERT INTO users (username, password, fullname) VALUES (?, ?, ?)");
            $stmt->bind_param("sss", $username, $password, $fullname);
            
            if ($stmt->execute()) {
                echo json_encode(array("success" => true, "message" => "success"));
            } else {
                echo json_encode(array("success" => false, "message" => "fail"));
            }
        }

        // Đóng statement
        $stmt->close();
    } else {
        echo json_encode(array("success" => false, "message" => "Invalid input"));
    }
}

?>
