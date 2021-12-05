<?php
    include_once 'config/config.php';
    include_once 'config/function.php';
    include_once 'config/loadData.php';
	
	header("Content-Type: application/json; charset=UTF-8");
    $get_folder = __DIR__ ; 

	$index = 0;
	$respon = array(); 
	$keyAkses = 'apiapi';
	$sign = 'blangkontemplate';

	if (empty($_GET['act'])) {
		$respon[$index]['result'] = 'null';
		$respon[$index]['pesan'] = 'Invalid action';
	} else {
		$headers = apache_request_headers();

		if (empty($headers['key'])) {
			$respon[$index]['result'] = 'null';
			$respon[$index]['pesan'] = 'Invalid key';
		} else {
			if ($headers['key'] == $keyAkses){
				if (!$koneksi) {
					$respon[$index]['result'] = 'null';
					$respon[$index]['pesan'] = 'MAAF GAGAL MENGHUBUNGKAN DENGAN SERVER';	
				} else {
					if ($_GET['act'] == 'deleteItem'){ 
						$id = $_POST['id'];
						$tbl = $_POST['tbl'];
						
						if (fnDeleteItem($koneksi, $id, $tbl)) {
							$respon[$index]['result'] = "SUKSES";
							$respon[$index]['pesan'] = 'DATA BERHASIL DI HAPUS';
						} else {
							$respon[$index]['result'] = "null";
							$respon[$index]['pesan'] = 'MAAF, DATA GAGAL HAPUS';
						}
					} elseif ($_GET['act'] == 'deleteItemWhere') {
						$respon = fnDeleteItemWhere($koneksi, $_POST['tbl'], $_POST['isWhere']);
					} elseif ($_GET['act'] == 'insertItem') {
						$respon = fnInsertItem($koneksi, $_POST['tbl'], $_POST['kol'], $_POST['val']);
					} elseif ($_GET['act'] == 'insertItemIsNull') {
						$respon = fnInsertItemIsNull($koneksi, $_POST['tbl'], $_POST['kol'], $_POST['val'], $_POST['isWhere']);
					} elseif ($_GET['act'] == 'insertItemIsNotNull') {
						$respon = fnInsertItemIsNotNull($koneksi, $_POST['tbl'], $_POST['kol'], $_POST['val'], $_POST['isWhere']);
					} elseif ($_GET['act'] == 'updateItem') {
						$respon = fnUpdateItem($koneksi, $_POST['tbl'], $_POST['val'], $_POST['isWhere']);	
					} elseif ($_GET['act'] == 'updateItemIsNull') {
						$respon = fnUpdateItemIsNull($koneksi, $_POST['tbl'], $_POST['val'], $_POST['id'], $_POST['isWhere']);
					} elseif ($_GET['act'] == 'updateItemIsNotNull') {
						$respon = fnUpdateItemIsNotNull($koneksi, $_POST['tbl'], $_POST['val'], $_POST['id'], $_POST['isWhere']);
					} elseif ($_GET['act'] == 'getData') {
						$respon = fnGetItem($koneksi, $_POST['tbl'], $_POST['val'], $_POST['isWhere'], $_POST['order'], $_POST['limit']);
					} elseif ($_GET['act']=='uploadFiles') {
						$folder = 'files/';
						$nmFile = $_POST['nmFile'];
		
						if(file_exists($folder.$nmFile)) {
							unlink( $folder.$nmFile);
						}
						
						if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $folder.$nmFile)) {
							$respon[$index]['result'] = "sukess";
							$respon[$index]['pesan'] = 'BERHASIL UPLOAD FILE';	
						} else {
							$respon[$index]['result'] = "null";
							$respon[$index]['pesan'] = 'MAAF, GAGAL UPLOAD FILE';
						}
					} else {
						$respon[$index]['result'] = "null";
						$respon[$index]['pesan'] = 'Invalid action';	
					}
				}
			} else {
				$respon[$index]['result'] = 'null';
				$respon[$index]['pesan'] = 'Invalid key';	
			}	
		}

		
	}
	
	echo json_encode($respon,JSON_PRETTY_PRINT);
?>