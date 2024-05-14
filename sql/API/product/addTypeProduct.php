<?php 

include '../connect.php';
if($_SERVER['REQUEST_METHOD'] === 'POST'){
    $tenloai = $_POST['tenloai'];
    $sql = "INSERT INTO loaisanpham (tenloai) VALUES ('$tenloai')";
    $result = mysqli_query($conn, $sql);
    if($result){
        echo json_encode(array("success" => true));
    }else{
        echo json_encode(array("success" => false));
    }
}elseif($_SERVER["REQUEST_METHOD"] === "DELETE" && isset($_GET['id'])){
    $id = $_GET['id'];
    $sql = "DELETE FROM loaisanpham WHERE id = $id";
    $result = mysqli_query($conn, $sql);
    if($result){
        echo json_encode(array("success" => true));
    }else{
        echo json_encode(array("success" => false));
    }
}

?>