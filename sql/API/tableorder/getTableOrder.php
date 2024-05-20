<?php

include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === "POST") {
    $ten = $_POST["ten"];
    $sql = "INSERT INTO tableorder (ten) VALUES ('$ten')";
    $result = mysqli_query($conn, $sql);
    if ($result) {
        echo json_encode(array("success" => true));
    } else {
        echo json_encode(array("success" => false));
    }
} elseif ($_SERVER['REQUEST_METHOD'] === "GET") {
    $sql = "SELECT * FROM tableorder";
    $result = mysqli_query($conn, $sql);
    if ($result && mysqli_num_rows($result) > 0) {
        $data = array();
        while ($row = mysqli_fetch_assoc($result)) {
            $tongtien = 0;
            $idban = $row["id"];
            // Sử dụng JOIN để kết nối các bảng và truy vấn dữ liệu cần thiết
            $sql_1 = "SELECT SUM(pr.gia * b.soluong) AS total_money
                      FROM products pr
                      INNER JOIN bill b ON b.idmon = pr.id
                      WHERE b.tinhtrang = 1 AND b.idban = '$idban'";
            $result_1 = mysqli_query($conn, $sql_1);
            $row_1 = mysqli_fetch_assoc($result_1);
            if ($row_1['total_money']) {
                $tongtien = $row_1['total_money'];
            }
            // Thêm tổng tiền vào mảng dữ liệu
            $row['total_money'] = $tongtien;
            $data[] = $row;
        }
        echo json_encode($data);
    } else {
        echo json_encode(array("success" => false, "message" => "Không có dữ liệu."));
    }
}

?>
