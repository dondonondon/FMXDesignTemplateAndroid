<?php

    header("Content-Type: application/json; charset=UTF-8");

    $rawData = file_get_contents("php://input");
    $input = json_decode($rawData);

    $data = [
        'status' => 200,
        'messages' => $input,
    ];

    echo json_encode($data, JSON_PRETTY_PRINT);

?>