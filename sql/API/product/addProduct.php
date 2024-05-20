<?php

include '../connect.php';

// Lấy dữ liệu từ POST request
$ten = $_POST['ten'];
$soluong = $_POST['soluong'];
$loai = $_POST['loai'];
$gia = $_POST['gia'];

// Thư mục lưu trữ hình ảnh
$target_dir = "../image/";
if (!file_exists($target_dir)) {
    mkdir($target_dir, 0777, true);
}

$new_filename = $ten . '.' . pathinfo($_FILES["image"]["name"], PATHINFO_EXTENSION);
$target_file = $target_dir . $new_filename;
$imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

// Kiểm tra kích thước file
if ($_FILES["image"]["size"] > 5000000) {
    echo json_encode(array("success" => false, "message" => "File quá lớn. Chỉ chấp nhận file có dung lượng nhỏ hơn 5MB."));
    exit();
}

// Kiểm tra định dạng file
if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg") {
    echo json_encode(array("success" => false, "message" => "Chỉ chấp nhận file JPG, JPEG, PNG."));
    exit();
}

// Upload file
if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
    $image = 'image/' . $new_filename;
    $stmt = $conn->prepare("INSERT INTO products (ten, loai, image, gia, soluong) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("sssdi", $ten, $loai, $image, $gia, $soluong);

    if ($stmt->execute()) {
        echo json_encode(array("success" => true, "message" => "Sản phẩm đã được thêm thành công", "file_path" => $target_file));
    } else {
        echo json_encode(array("success" => false, "message" => "Có lỗi xảy ra khi thêm sản phẩm vào cơ sở dữ liệu."));
    }
    $stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Có lỗi xảy ra khi tải ảnh lên máy chủ."));
}

// Đóng kết nối
$conn->close();

?>
