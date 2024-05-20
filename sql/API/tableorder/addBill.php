<?php
include '../connect.php';

if ($_SERVER['REQUEST_METHOD'] === "POST") {
    $idban = $_POST["idban"];
    $idmon = $_POST["idmon"];

    // Chuẩn bị và thực hiện câu lệnh truy vấn
    $stmt = $conn->prepare("SELECT soluong FROM products WHERE id = ?");
    $stmt->bind_param("i", $idmon);
    $stmt->execute();
    $stmt->bind_result($soluongProduct);
    $stmt->fetch();
    $stmt->close();

    if ($soluongProduct > 0) {
        $stmt = $conn->prepare("SELECT SUM(soluong) AS soluong FROM bill WHERE idmon = ? AND tinhtrang = 0");
        $stmt->bind_param("i", $idmon);
        $stmt->execute();
        $stmt->bind_result($soluongBill);
        $stmt->fetch();
        $stmt->close();

        if ($soluongBill >= $soluongProduct) {
            echo json_encode(array("success" => false, "thongbao" => "Sản phẩm đã được chọn hết trong hàng chờ"));
        } else {
            $stmt = $conn->prepare("SELECT id, soluong FROM bill WHERE idban = ? AND idmon = ? AND tinhtrang = 0");
            $stmt->bind_param("ii", $idban, $idmon);
            $stmt->execute();
            $stmt->store_result();

            if ($stmt->num_rows > 0) {
                $stmt->bind_result($id, $soluongBillItem);
                $stmt->fetch();
                $stmt->close();

                $soluongBillItem += 1;
                $stmt = $conn->prepare("UPDATE bill SET soluong = ? WHERE id = ? AND tinhtrang = 0");
                $stmt->bind_param("ii", $soluongBillItem, $id);
                if ($stmt->execute()) {
                    echo json_encode(array("success" => true));
                }
                $stmt->close();
            } else {
                $stmt->close();
                $stmt = $conn->prepare("INSERT INTO bill (idban, idmon, giovao, soluong) VALUES (?, ?, NOW(), 1)");
                $stmt->bind_param("ii", $idban, $idmon);
                if ($stmt->execute()) {
                    echo json_encode(array("success" => true));
                } else {
                    echo json_encode(array("success" => false));
                }
                $stmt->close();
            }
        }
    } else {
        echo json_encode(array("success" => false, "thongbao" => "Đã hết hàng"));
    }
} elseif ($_SERVER['REQUEST_METHOD'] === "GET" && isset($_GET["id"])) {
    $tongtien = 0;
    $idban = $_GET["id"];

    $stmt = $conn->prepare("SELECT SUM(b.soluong) AS soluong FROM bill b JOIN products pr ON pr.id = b.idmon WHERE b.idban = ?");
    $stmt->bind_param("i", $idban);
    $stmt->execute();
    $stmt->bind_result($totalQuantity);
    $stmt->fetch();
    $stmt->close();

    if ($totalQuantity) {
        $stmt = $conn->prepare("SELECT pr.gia, b.soluong FROM bill b JOIN products pr ON pr.id = b.idmon WHERE b.idban = ? AND b.tinhtrang = 1");
        $stmt->bind_param("i", $idban);
        $stmt->execute();
        $stmt->bind_result($gia, $soluong);

        while ($stmt->fetch()) {
            $tongtien += $soluong * $gia;
        }
        $stmt->close();

        echo json_encode(array("success" => true, "tongtien" => $tongtien, "soluong" => $totalQuantity));
    } else {
        echo json_encode(array("success" => false));
    }
}
?>
