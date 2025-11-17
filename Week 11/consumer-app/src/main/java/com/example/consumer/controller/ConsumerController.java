package com.example.consumer.controller;

import com.example.consumer.service.KafkaConsumerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ConsumerController {

    @Autowired
    private KafkaConsumerService consumerService;

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Kafka Consumer");
        response.put("timestamp", java.time.LocalDateTime.now().toString());
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("statistics", consumerService.getStatistics());
        response.put("timestamp", java.time.LocalDateTime.now().toString());
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/stats/reset")
    public ResponseEntity<Map<String, String>> resetStatistics() {
        consumerService.resetStatistics();
        
        Map<String, String> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "Statistics reset successfully");
        response.put("timestamp", java.time.LocalDateTime.now().toString());
        
        return ResponseEntity.ok(response);
    }
}