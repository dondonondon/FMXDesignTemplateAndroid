<?php
	header("Content-Type: application/json; charset=UTF-8");

    function sendPush($to, $title, $body, $icon, $url) {
        define('FCM_AUTH_KEY', 'AAAAN0hHhzM:APA91bEX3ET3efvwH_ODYNujwdyp62L1Fnc3yFy8Z6pUhsYlz9Thfgz6Y88cF39dLuXpU6bUqPSY5_fhwOF4KsA-LmOrPIUX0thGhUfhqI7mcSwQ72F7NZFBTdAnerhTtMB-jnUv3YBX');
        $postdata = json_encode(
            [
                'notification' => 
                    [
                        'title' => $title,
                        'body' => $body,
                        'icon' => $icon,
                        'click_action' => $url,
                        'target' => 'com.blangkon.prjTemplate2021'
                    ]
                ,
                'to' => $to
            ]
        );
    
        $opts = array('http' =>
            array(
                'method'  => 'POST',
                'header'  => 'Content-type: application/json'."\r\n"
                            .'Authorization: key='.FCM_AUTH_KEY."\r\n",
                'content' => $postdata
            )
        );
    
        $context  = stream_context_create($opts);
    
        $result = file_get_contents('https://fcm.googleapis.com/fcm/send', false, $context);

        return json_decode($result);
    }
	
    $respon =sendPush($_GET['device_id'], $_GET['title'], $_GET['body'], ''/* url icon */, ''/* url action click */);
    
	echo json_encode($respon,JSON_PRETTY_PRINT);
?>