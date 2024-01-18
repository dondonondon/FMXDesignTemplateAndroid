<?php

    header("Content-Type: application/json; charset=UTF-8");

    http_response_code(200);
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $data = [
            'status' => 200,
            'messages' => "hello world. Success request on sample get",
        ];
    } else {
        http_response_code(400);    
        $data = [
            'status' => 400,
            'messages' => "invalid method",
        ];  
    }

    echo json_encode($data, JSON_PRETTY_PRINT);

?>