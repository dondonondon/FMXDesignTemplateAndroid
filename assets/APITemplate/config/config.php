<?php
    $koneksi = @mysqli_connect("localhost", "root", "");
    $database = mysqli_select_db($koneksi, "db_template");
?>