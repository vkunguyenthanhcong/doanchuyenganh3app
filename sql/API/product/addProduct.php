<?php

include '../connect.php';
    $ten = $_POST['ten'];
    $loai = $_POST['soluong'];
    $loai = $_POST['loai'];
    $gia = $_POST['gia'];
 
    $target_dir = "../image/";
    if (!file_exists($target_dir)) {
        mkdir($target_dir, 0777, true);
    }
    $new_filename = $ten . '.' . pathinfo($_FILES["image"]["name"], PATHINFO_EXTENSION);
    $target_file = $target_dir . $new_filename;
    $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));
    if ($_FILES["image"]["size"] > 5000000) {
        echo "File quá lớn. Chỉ chấp nhận file có dung lượng nhỏ hơn 500KB.";
        exit();
    }
    if ($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg") {
        echo "Chỉ chấp nhận file JPG, JPEG, PNG.";
        exit();
    }
    if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
        // Trả về đường dẫn file ảnh sau khi upload thành công
        $response["file_path"] = $target_file;
        echo json_encode($response);
    } else {
        echo "Có lỗi xảy ra khi tải ảnh lên máy chủ.";
    }
    $image = 'image/'.$new_filename;
    $sql = "INSERT INTO products (ten, loai, image, gia, soluong) VALUES ('$ten', '$loai', '$image', '$gia', '$soluong')";
    mysqli_query($conn, $sql);

?>