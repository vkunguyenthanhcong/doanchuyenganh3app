<?php
include '../connect.php';
if($_SERVER['REQUEST_METHOD'] === "GET" && isset($_GET['idban'])){
    $idban = $_GET['idban'];
    $sql = "SELECT b.soluong, pr.ten, pr.gia FROM bill b, products pr WHERE b.tinhtrang = 0 AND b.idban = '$idban' AND pr.id = b.idmon";
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) > 0){
        $data = array();
        while ($row = mysqli_fetch_assoc($result)) {
            // Parse date to suitable format
            $data[] = $row;
        }
        echo json_encode($data);
    }else{
        $data = array();
        echo json_encode($data);
    }
}elseif($_SERVER['REQUEST_METHOD'] === "GET" && isset($_GET['id']) && isset($_GET['tienChuaXacNhan'])){
    $idban = $_GET['id'];
    $sql = "SELECT SUM(pr.gia) AS tongtien FROM bill b , products pr WHERE b.tinhtrang = 0 AND b.idban = '$idban' AND pr.id = b.idmon";
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) > 0){
        $row = mysqli_fetch_assoc($result);
        echo json_encode(array('tongtien' => $row['tongtien']));
    }
}elseif($_SERVER['REQUEST_METHOD'] === 'POST'){
    $idban = $_POST['idban'];
    $sql = "UPDATE bill SET tinhtrang = 1 WHERE idban = '$idban' AND tinhtrang = 0";
    $result = mysqli_query($conn, $sql);
}elseif($_SERVER['REQUEST_METHOD'] === "GET" && isset($_GET['idBanDaXacNhan'])){
    $idban = $_GET['idBanDaXacNhan'];
    $sql = "SELECT b.soluong, pr.ten, pr.gia FROM bill b, products pr WHERE b.tinhtrang = 1 AND b.idban = '$idban' AND pr.id = b.idmon";
    $result = mysqli_query($conn, $sql);
    if(mysqli_num_rows($result) > 0){
        $data = array();
        while ($row = mysqli_fetch_assoc($result)) {
            // Parse date to suitable format
            $data[] = $row;
        }
        echo json_encode($data);
    }else{
        $data = array();
        echo json_encode($data);
    }
}elseif($_SERVER['REQUEST_METHOD'] === "GET" && isset( $_GET["getGioVaoDaXacNhan"])){
    $idban = $_GET["getGioVaoDaXacNhan"];
    $sql = "SELECT b.giovao FROM bill b WHERE b.idban = '$idban' ORDER BY b.giovao ASC";
    $result = mysqli_query($conn, $sql);
    $sql_1 = "SELECT SUM(pr.gia) AS tongtien FROM bill b, products pr WHERE b.idban = '$idban' AND tinhtrang = 1 AND b.idmon = pr.id";
    $result_1 = mysqli_query($conn, $sql_1);
    if(mysqli_num_rows($result_1) > 0 && mysqli_num_rows($result) > 0){
        $row = mysqli_fetch_assoc($result);
        $row_1 = mysqli_fetch_assoc($result_1);
        echo json_encode(array("success" => true, "time"=> $row['giovao'], "tongtien" => $row_1['tongtien']));
    }else{
        echo json_encode(array("success" => false));
    }

}elseif($_SERVER['REQUEST_METHOD'] === "DELETE" && isset($_GET['idBanHuy'])){
    $idban = $_GET['idBanHuy'];
    $sql = "DELETE FROM bill WHERE idban = '$idban' AND tinhtrang = 0";
    $result = mysqli_query($conn, $sql);
    if($result){
        echo json_encode(array("success" => true));
    }else{
        echo json_encode(array("success" => false));
    }
}



?>