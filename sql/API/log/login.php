<?php
include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (isset($_GET['username'])) {
        $username = $_GET['username'];
        
        // Sử dụng prepared statement
        $stmt = $conn->prepare("SELECT password FROM users WHERE username = ?");
        $stmt->bind_param("s", $username);
        $stmt->execute();
        $stmt->bind_result($password);
        
        if ($stmt->fetch()) {
            echo json_encode(array("success" => true, "password" => $password));
        } else {
            echo json_encode(array("success" => false, "message" => "User not found"));
        }
        
        $stmt->close();
    } else {
        echo json_encode(array("success" => false, "message" => "Username not provided"));
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['username']) && isset($_POST['password'])) {
        $username = $_POST['username'];
        $password = $_POST['password'];
        
        // Sử dụng prepared statement
        $stmt = $conn->prepare("SELECT fullname, roll FROM users WHERE username = ? AND password = ?");
        $stmt->bind_param("ss", $username, $password);
        $stmt->execute();
        $stmt->bind_result($fullname, $roll);
        
        if ($stmt->fetch()) {
            echo json_encode(array("success" => true, "message" => "success", "fullname" => $fullname, "roll" => $roll));
        } else {
            echo json_encode(array("success" => false, "message" => "fail"));
        }
        
        $stmt->close();
    } else {
        echo json_encode(array("success" => false, "message" => "Username or password not provided"));
    }
} else {
    echo json_encode(array("success" => false, "message" => "Invalid request method"));
}
?>
