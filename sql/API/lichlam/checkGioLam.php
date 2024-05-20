<?php
// Kết nối đến cơ sở dữ liệu
include '../connect.php';

if (isset($_GET['username']) && isset($_GET['timenow'])) {
    $nhanvien = $_GET['username'];
    $target_time = $_GET['timenow'];

    // Sử dụng prepared statement để tránh SQL injection
    $sql = "
        SELECT ca.ca, ll.tinhtrang 
        FROM calamviec ca
        JOIN lichlam ll ON ca.id = ll.idca
        WHERE ll.nhanvien = ?
        ORDER BY ABS(TIME_TO_SEC(TIMEDIFF(STR_TO_DATE(ca.ca, '%H:%i'), STR_TO_DATE(?, '%H:%i')))) ASC
        LIMIT 1
    ";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $nhanvien, $target_time);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Lấy dữ liệu từ kết quả truy vấn
        $row = $result->fetch_assoc();
        $nearest_time = $row['ca'];
        $tinhtrang = $row['tinhtrang'];
        echo json_encode(array("success" => true, "time" => $nearest_time, "tinhtrang" => $tinhtrang));
    } else {
        echo json_encode(array("success" => false, "message" => "No records found"));
    }

    // Đóng statement
    $stmt->close();
} else {
    echo json_encode(array("success" => false, "message" => "Invalid input"));
}

// Đóng kết nối
$conn->close();
?>
