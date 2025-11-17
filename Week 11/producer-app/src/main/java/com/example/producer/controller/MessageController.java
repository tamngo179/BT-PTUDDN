package com.example.producer.controller;

import com.example.producer.model.UserMessage;
import com.example.producer.service.KafkaProducerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class MessageController {

    @Autowired
    private KafkaProducerService producerService;

    @PostMapping("/messages")
    public ResponseEntity<Map<String, String>> sendMessage(@RequestBody UserMessage message) {
        // Generate ID if not provided
        if (message.getId() == null || message.getId().isEmpty()) {
            message.setId(UUID.randomUUID().toString());
        }
        
        producerService.sendMessage(message);
        
        Map<String, String> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "Message sent to Kafka");
        response.put("messageId", message.getId());
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/messages/partition/{partition}")
    public ResponseEntity<Map<String, String>> sendMessageToPartition(
            @RequestBody UserMessage message, 
            @PathVariable int partition) {
        
        if (message.getId() == null || message.getId().isEmpty()) {
            message.setId(UUID.randomUUID().toString());
        }
        
        producerService.sendMessageToPartition(message, partition);
        
        Map<String, String> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "Message sent to Kafka partition " + partition);
        response.put("messageId", message.getId());
        response.put("partition", String.valueOf(partition));
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Kafka Producer");
        response.put("timestamp", java.time.LocalDateTime.now().toString());
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/messages/bulk")
    public ResponseEntity<Map<String, Object>> sendBulkMessages(@RequestParam(defaultValue = "10") int count) {
        for (int i = 0; i < count; i++) {
            UserMessage message = new UserMessage(
                UUID.randomUUID().toString(),
                "User" + i,
                "user" + i + "@example.com",
                "CREATE",
                "Bulk message " + i
            );
            producerService.sendMessage(message);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "Bulk messages sent to Kafka");
        response.put("count", count);
        
        return ResponseEntity.ok(response);
    }
}