<?php
    include_once 'function.php';
	
    function fnLoadRiwayat($kon, $token){
		$index = 0;
		
		$SQLAdd =
			"SELECT * FROM lapas_pendaftaran WHERE fcm = '".$token."' ORDER BY tgl DESC LIMIT 20";

		$query = mysqli_query($kon, $SQLAdd);

		if (mysqli_num_rows($query) > 0){
			while ($list = mysqli_fetch_assoc($query)) {
				$respon[] = $list;
			}
		} elseif (mysqli_num_rows($query) == 0){
            $respon[$index]['result'] = 'null';	
			$respon[$index]['pesan'] = 'MAAF, BELUM ADA DATA';	
        } else {
            $respon[$index]['result'] = 'null';	
			$respon[$index]['pesan'] = 'BERMASALAH SAAT MENGAMBIL DATA';	
        }

		return $respon;
	}
	
    
?>