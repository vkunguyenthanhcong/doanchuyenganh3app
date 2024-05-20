<?php
include '../connect.php';

// Kiểm tra xem dữ liệu đầu vào có tồn tại không
if(isset($_POST['ten']) && isset($_POST['loai']) && isset($_POST['gia']) && isset($_POST['soluong'])){
    // Lấy dữ liệu từ POST
    $ten = $_POST['ten'];
    $loai = $_POST['loai'];
    $gia = $_POST['gia'];
    $soluong = $_POST['soluong'];

    // Chuẩn bị truy vấn INSERT với prepared statements
    $sql = "INSERT INTO products (ten, loai, gia, soluong) VALUES (?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssii", $ten, $loai, $gia, $soluong);

    // Thực thi truy vấn
    if($stmt->execute()){
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false, "message" => "Lỗi khi thêm sản phẩm."));
    }

    // Đóng prepared statement
    $stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Dữ liệu không hợp lệ."));
}
?>
