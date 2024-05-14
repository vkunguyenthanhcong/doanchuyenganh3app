<?php 

include '../connect.php';
if($_SERVER['REQUEST_METHOD'] === "GET"){
    $sql = "SELECT * FROM products ORDER BY hot ASC limit 5";
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) > 0){
        $data = array();
        while ($row = mysqli_fetch_assoc($result)) {
            // Parse date to suitable format
            $data[] = $row;
            
        }
        echo json_encode($data);
}
    else{
        echo json_encode(array("success" => false, "message" => "fail"));
    }
}
?>