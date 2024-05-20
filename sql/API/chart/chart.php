<?php
include '../connect.php';

$sql = "SELECT DATE(giovao) AS date, SUM(tongtien) AS total FROM hoadon GROUP BY DATE(giovao) ORDER BY DATE(giovao) DESC LIMIT 7";

$result = mysqli_query($conn, $sql);

$data = array();
if ($result) {
    if (mysqli_num_rows($result) > 0) {
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
    }
    echo json_encode($data);
} else {
    echo json_encode(array("success" => false, "message" => "Error executing query: " . mysqli_error($conn)));
}

$conn->close();
?>
