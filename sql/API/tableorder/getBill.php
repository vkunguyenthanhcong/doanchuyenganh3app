<?php
include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === "GET") {
    if (isset($_GET['idban'])) {
        $idban = $_GET['idban'];
        $stmt = $conn->prepare("SELECT b.soluong, pr.ten, pr.gia FROM bill b JOIN products pr ON pr.id = b.idmon WHERE b.tinhtrang = 0 AND b.idban = ?");
        $stmt->bind_param("i", $idban);
        $stmt->execute();
        $result = $stmt->get_result();
        $data = array();
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode($data);
    } elseif (isset($_GET['id']) && isset($_GET['tienChuaXacNhan'])) {
        $idban = $_GET['id'];
        $stmt = $conn->prepare("SELECT pr.gia, b.soluong FROM bill b JOIN products pr ON pr.id = b.idmon WHERE b.tinhtrang = 0 AND b.idban = ?");
        $stmt->bind_param("i", $idban);
        $stmt->execute();
        $result = $stmt->get_result();
        $tongtien = 0;
        while ($row = $result->fetch_assoc()) {
            $tongtien += $row['gia'] * $row['soluong'];
        }
        echo json_encode(array('tongtien' => $tongtien));
    } elseif (isset($_GET['idBanDaXacNhan'])) {
        $idban = $_GET['idBanDaXacNhan'];
        $stmt = $conn->prepare("SELECT b.soluong, pr.ten, pr.gia FROM bill b JOIN products pr ON pr.id = b.idmon WHERE b.tinhtrang = 1 AND b.idban = ?");
        $stmt->bind_param("i", $idban);
        $stmt->execute();
        $result = $stmt->get_result();
        $data = array();
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode($data);
    } elseif (isset($_GET['getGioVaoDaXacNhan'])) {
        $idban = $_GET['getGioVaoDaXacNhan'];
        $stmt = $conn->prepare("SELECT b.giovao FROM bill b WHERE b.idban = ? ORDER BY b.giovao ASC");
        $stmt->bind_param("i", $idban);
        $stmt->execute();
        $result = $stmt->get_result();
        $tongtien = 0;
        $stmt_1 = $conn->prepare("SELECT pr.gia, b.soluong FROM bill b JOIN products pr ON pr.id = b.idmon WHERE b.idban = ? AND b.tinhtrang = 1");
        $stmt_1->bind_param("i", $idban);
        $stmt_1->execute();
        $result_1 = $stmt_1->get_result();
        while ($row_1 = $result_1->fetch_assoc()) {
            $tongtien += $row_1['soluong'] * $row_1['gia'];
        }
        if ($row = $result->fetch_assoc()) {
            echo json_encode(array("success" => true, "time" => $row['giovao'], "tongtien" => $tongtien));
        } else {
            echo json_encode(array("success" => false));
        }
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['idban'])) {
        $idban = $_POST['idban'];
        $stmt = $conn->prepare("UPDATE bill SET tinhtrang = 1 WHERE idban = ? AND tinhtrang = 0");
        $stmt->bind_param("i", $idban);
        $stmt->execute();
        echo json_encode(array("success" => $stmt->affected_rows > 0));
    }
} elseif ($_SERVER['REQUEST_METHOD'] === "DELETE") {
    if (isset($_GET['idBanHuy'])) {
        $idban = $_GET['idBanHuy'];
        $stmt = $conn->prepare("DELETE FROM bill WHERE idban = ? AND tinhtrang = 0");
        $stmt->bind_param("i", $idban);
        $stmt->execute();
        echo json_encode(array("success" => $stmt->affected_rows > 0));
    }
}
?>
