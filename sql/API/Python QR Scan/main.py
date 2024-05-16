import sys
import cv2
import numpy as np
import mysql.connector
from pyzbar import pyzbar
from PyQt5 import QtCore, QtGui, QtWidgets
from PyQt5.QtGui import QImage, QPixmap
from datetime import datetime
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QMessageBox

from PyQt5.QtCore import QTimer
class Ui_MainWindow(object):
    fname = ""
    usname = ""
    id = ""
    def setupUi(self, MainWindow):
        MainWindow.setObjectName("MainWindow")
        MainWindow.resize(1280, 714)
        self.centralwidget = QtWidgets.QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")
        self.groupBox = QtWidgets.QGroupBox(self.centralwidget)
        self.groupBox.setGeometry(QtCore.QRect(10, 0, 691, 671))
        self.groupBox.setObjectName("groupBox")
        self.frame = QtWidgets.QFrame(self.groupBox)
        self.frame.setGeometry(QtCore.QRect(9, 19, 671, 641))
        self.frame.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame.setObjectName("frame")
        
        # Add QLabel to display the camera feed
        self.label_video = QtWidgets.QLabel(self.frame)
        self.label_video.setGeometry(QtCore.QRect(0, 0, 671, 641))
        self.label_video.setObjectName("label_video")
        
        self.groupBox_2 = QtWidgets.QGroupBox(self.centralwidget)
        self.groupBox_2.setGeometry(QtCore.QRect(710, 0, 561, 671))
        self.groupBox_2.setObjectName("groupBox_2")
        self.frame_2 = QtWidgets.QFrame(self.groupBox_2)
        self.frame_2.setGeometry(QtCore.QRect(10, 20, 541, 641))
        self.frame_2.setFrameShape(QtWidgets.QFrame.StyledPanel)
        self.frame_2.setFrameShadow(QtWidgets.QFrame.Raised)
        self.frame_2.setObjectName("frame_2")
        self.pushButton = QtWidgets.QPushButton(self.frame_2)
        self.pushButton.setGeometry(QtCore.QRect(190, 170, 171, 51))
        font = QtGui.QFont()
        font.setPointSize(16)
        self.pushButton.setFont(font)
        self.pushButton.setObjectName("pushButton")
        self.pushButton_2 = QtWidgets.QPushButton(self.frame_2)
        self.pushButton_2.setGeometry(QtCore.QRect(190, 230, 171, 51))
        font = QtGui.QFont()
        font.setPointSize(16)
        self.pushButton_2.setFont(font)
        self.pushButton_2.setObjectName("pushButton_2")
        self.label = QtWidgets.QLabel(self.frame_2)
        self.label.setGeometry(QtCore.QRect(80, 350, 421, 21))
        font = QtGui.QFont()
        font.setPointSize(12)
        self.label.setFont(font)
        self.label.setObjectName("label")
        self.label_2 = QtWidgets.QLabel(self.frame_2)
        self.label_2.setGeometry(QtCore.QRect(80, 390, 421, 21))
        font = QtGui.QFont()
        font.setPointSize(12)
        self.label_2.setFont(font)
        self.label_2.setObjectName("label_2")
        MainWindow.setCentralWidget(self.centralwidget)
        self.menubar = QtWidgets.QMenuBar(MainWindow)
        self.menubar.setGeometry(QtCore.QRect(0, 0, 1280, 21))
        self.menubar.setObjectName("menubar")
        MainWindow.setMenuBar(self.menubar)
        self.statusbar = QtWidgets.QStatusBar(MainWindow)
        self.statusbar.setObjectName("statusbar")
        MainWindow.setStatusBar(self.statusbar)

        self.retranslateUi(MainWindow)
        QtCore.QMetaObject.connectSlotsByName(MainWindow)

    def retranslateUi(self, MainWindow):
        _translate = QtCore.QCoreApplication.translate
        MainWindow.setWindowTitle(_translate("MainWindow", "MainWindow"))
        self.groupBox.setTitle(_translate("MainWindow", "Camera"))
        self.groupBox_2.setTitle(_translate("MainWindow", "Điểm danh"))
        self.pushButton.setText(_translate("MainWindow", "Check In"))
        self.pushButton.setEnabled(False)
        self.pushButton_2.setText(_translate("MainWindow", "Check Out"))
        self.pushButton_2.setEnabled(False)
        self.label.setText(_translate("MainWindow", f"Họ và tên : {self.fname}"))
        self.label_2.setText(_translate("MainWindow", "Tình trạng  Check In Thành Công | Check In Thất Bại"))

class MainWindow(QtWidgets.QMainWindow, Ui_MainWindow):
    def __init__(self, parent=None):
        super(MainWindow, self).__init__(parent)
        self.setupUi(self)
        self.pushButton.clicked.connect(self.check_in)
        self.pushButton_2.clicked.connect(self.check_out)
        # Set up the camera feed
        self.timer = QtCore.QTimer(self, interval=30)
        self.timer.timeout.connect(self.update_frame)
        self.cap = cv2.VideoCapture(0)
        self.timer.start()

        # MySQL connection setup
        self.db_connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password="",  # Replace with your MySQL root password
            database="coffee"    # Replace with your database name
        )
        self.cursor = self.db_connection.cursor()

        self.scanQR()

    def update_frame(self):
        ret, frame = self.cap.read()
        if ret:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

            # Decode QR codes in the frame
            decoded_objects = pyzbar.decode(frame)
            for obj in decoded_objects:
                self.qr_data = obj.data.decode('utf-8')
                cv2.putText(frame, "Scanned QR: " + self.qr_data, (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2, cv2.LINE_AA)
                self.scanQR(self.qr_data)
                break

            # Convert to QImage and display
            image = QImage(frame, frame.shape[1], frame.shape[0], QImage.Format_RGB888)
            self.label_video.setPixmap(QPixmap.fromImage(image))

    def check_in(self):
        current_datetime = datetime.now()
        formatted_datetime = current_datetime.strftime("%Y-%m-%d %H:%M:%S")
        sql = f"UPDATE lichlam SET tinhtrang = 1, checkin = '{formatted_datetime}' WHERE id = '{self.id}' AND nhanvien = '{self.usname}'"
        self.cursor.execute(sql)
        if(self.db_connection.commit() == None):
            self.label_2.setText("Check In Thành Công")
            self.label_2.setStyleSheet("color: green")  # Set text color to green
            font = QFont("Arial", 16)  # Create QFont object with Arial font and size 16
            self.label_2.setFont(font)

            self.timer = QTimer(self)
            self.timer.setSingleShot(True)  # Execute only once
            self.timer.timeout.connect(self.reset)
            
            # Start the timer with a 10-second interval
            self.timer.start(30000)
        else:
            pass
    def reset(self):
        self.usname = ""
        self.id = ""
        self.label.setText("Họ và tên : ")
        self.label_2.setText("Check in : ")
        self.label_2.setStyleSheet("color: black")  # Set text color to green
        font = QFont("Arial", 12)  # Create QFont object with Arial font and size 16
        self.label_2.setFont(font)
        self.pushButton.setEnabled(False)
    def scanQR(self, username=None):
        if username:
            try:
                current_time = datetime.now()
                target_time = current_time.strftime("%H:%M")
                daynow = current_time.strftime("%Y/%m/%d")
                
                sql = f"SELECT ca.ca, ll.id FROM calamviec ca, lichlam ll WHERE ll.tinhtrang = 0 AND ca.ngay = '{daynow}' AND ca.id = ll.idca AND ll.nhanvien = '{username}' ORDER BY ABS(TIME_TO_SEC(TIMEDIFF(STR_TO_DATE(ca.ca, '%H:%i'), STR_TO_DATE('{target_time}', '%H:%i')))) ASC LIMIT 1"
                self.cursor.execute(sql)
                result = self.cursor.fetchone()
                if result is not None:
                    self.id = result[1]
                    r = self.is_time_in_range(target_time, result[0])
                    calamviec = result[0]
                    self.usname = username
                    sql = f"SELECT fullname FROM users WHERE username = '{username}'"
                    self.cursor.execute(sql)
                    result = self.cursor.fetchone()
                    if result:
                        self.fname = result[0]
                        self.label.setText(f"Họ và tên : {self.fname} | Ca làm việc : {calamviec}")
                        if(r == True):
                            self.pushButton.setEnabled(True)
                        else:
                            self.pushButton.setEnabled(False)
                    else:
                        self.label_2.setText("Nhân viên không có trên hệ thống")
                        self.pushButton.setEnabled(False)
                else:
                    sql = f"SELECT ca.ca, ll.id FROM calamviec ca, lichlam ll WHERE ll.tinhtrang = 1 AND ca.ngay = '{daynow}' AND ca.id = ll.idca AND ll.nhanvien = '{username}' ORDER BY ABS(TIME_TO_SEC(TIMEDIFF(STR_TO_DATE(ca.ca, '%H:%i'), STR_TO_DATE('{target_time}', '%H:%i')))) ASC LIMIT 1"
                    self.cursor.execute(sql)
                    result = self.cursor.fetchone()
                    if result is not None:
                        self.id = result[1]
                        r = self.is_time_in_range(target_time, result[0])
                        calamviec = result[0]
                        self.usname = username
                        sql = f"SELECT fullname FROM users WHERE username = '{username}'"
                        self.cursor.execute(sql)
                        result = self.cursor.fetchone()
                        if result:
                            self.fname = result[0]
                            self.label.setText(f"Họ và tên : {self.fname} | Ca làm việc : {calamviec}")
                            self.label_2.setText(f"Tình trạng : Đang làm việc")
                            if(r == True):
                                self.pushButton_2.setEnabled(True)
                            else:
                                self.pushButton_2.setEnabled(True)
                        else:
                            self.label_2.setText("Nhân viên không có trên hệ thống")
                            self.pushButton_2.setEnabled(True)
                    else:
                        msg_box = QMessageBox()
                        msg_box.setIcon(QMessageBox.Information)
                        msg_box.setWindowTitle("Thông Báo")
                        msg_box.setText("Không có lịch làm phù hợp.")
                        msg_box.exec_()
            except mysql.connector.Error as err:
                self.pushButton.setEnabled(False)
                self.label_2.setText(f"({err})")
        else:
            self.pushButton.setEnabled(False)
            self.label_2.setText("Điểm danh : ")
    
    def is_time_in_range(self, time_str, time_range_str):
        # Parse the time range string
        start_str, end_str = time_range_str.split(" - ")
        start_time = datetime.strptime(start_str, "%H:%M")
        end_time = datetime.strptime(end_str, "%H:%M")

        # Parse the given time string
        given_time = datetime.strptime(time_str, "%H:%M")

        # Check if the given time is within the range
        return start_time <= given_time <= end_time

    def check_out(self):
        sql = f"SELECT u.luong, ll.checkin FROM users u, lichlam ll WHERE u.username = '{self.usname}' AND ll.nhanvien = '{self.usname}' AND tinhtrang = 1"
        self.cursor.execute(sql)
        result = self.cursor.fetchone()
        luong = result[0] / 60
        checkin = result[1]
        convertToDateTime = datetime.strptime(f"{checkin}", "%Y-%m-%d %H:%M:%S")

        # Thời gian hiện tại
        current_datetime = datetime.now()

        # Chuyển đổi thời gian hiện tại thành chuỗi
        formatted_datetime = current_datetime.strftime("%Y-%m-%d %H:%M:%S")

        # Lấy giờ và phút từ đối tượng datetime và chuyển thành chuỗi
        checkInTime = convertToDateTime.strftime("%H:%M")
        checkOutTime = current_datetime.strftime("%H:%M")

        # Chuyển đổi giờ và phút thành đối tượng datetime
        checkInTime_obj = datetime.strptime(checkInTime, "%H:%M")
        checkOutTime_obj = datetime.strptime(checkOutTime, "%H:%M")
        time_difference = checkOutTime_obj - checkInTime_obj
        minutes_difference = int(time_difference.total_seconds() / 60)
        
        tinhLuong = luong * minutes_difference

        sql = f"UPDATE lichlam SET tongluong = '{tinhLuong}' ,tinhtrang = 2, checkout = '{formatted_datetime}' WHERE id = '{self.id}' AND nhanvien = '{self.usname}' AND tinhtrang = 1"
        self.cursor.execute(sql)
        if(self.db_connection.commit() == None):
            self.label_2.setText("Check Out Thành Công")
            self.label_2.setStyleSheet("color: green")  # Set text color to green
            font = QFont("Arial", 16)  # Create QFont object with Arial font and size 16
            self.label_2.setFont(font)
            self.pushButton_2.setEnabled(False)
            self.timer = QTimer(self)
            self.timer.setSingleShot(True)  # Execute only once
            self.timer.timeout.connect(self.reset)
            
            # Start the timer with a 10-second interval
            self.timer.start(30000)
        else:
            pass

    def closeEvent(self, event):
        self.cap.release()
        self.db_connection.close()
        event.accept()

def main():
    app = QtWidgets.QApplication(sys.argv)
    main_window = MainWindow()
    main_window.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
