<?php 

include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === "GET") {
    $sql = "SELECT * FROM products";
    $result = mysqli_query($conn, $sql);
    
    if ($result && mysqli_num_rows($result) > 0) {
        $data = array();
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
        echo json_encode($data);
    } else {
        echo json_encode(array("success" => false, "message" => "Không có dữ liệu."));
    }
} elseif ($_SERVER['REQUEST_METHOD'] === "DELETE" && isset($_GET['id'])) {
    $id = $_GET['id'];
    $sql = "DELETE FROM products WHERE id = ?";
    
    // Sử dụng Prepared Statements để ngăn chặn SQL injection
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $id);
    
    if ($stmt->execute()) {
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false, "message" => "Xóa bản ghi không thành công."));
    }
    $stmt->close();
}

// Đóng kết nối
$conn->close();

?>
