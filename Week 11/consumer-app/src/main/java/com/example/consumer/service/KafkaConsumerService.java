package com.example.consumer.service;

import com.example.consumer.model.UserMessage;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;

import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

@Service
public class KafkaConsumerService {

    private static final Logger logger = LoggerFactory.getLogger(KafkaConsumerService.class);
    
    private final AtomicLong totalMessagesReceived = new AtomicLong(0);
    private final Map<Integer, AtomicLong> partitionMessageCount = new ConcurrentHashMap<>();
    private final Map<String, AtomicLong> actionCount = new ConcurrentHashMap<>();

    @KafkaListener(topics = "${app.kafka.topic.name}", groupId = "${spring.kafka.consumer.group-id}")
    public void consumeMessage(
            @Payload UserMessage message,
            @Header(KafkaHeaders.RECEIVED_TOPIC) String topic,
            @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
            @Header(KafkaHeaders.OFFSET) long offset,
            ConsumerRecord<String, UserMessage> consumerRecord) {
        
        logger.info("📨 Received message from topic: {}, partition: {}, offset: {}", topic, partition, offset);
        logger.info("📝 Message content: {}", message);
        logger.info("🔑 Message key: {}", consumerRecord.key());
        
        // Update statistics
        totalMessagesReceived.incrementAndGet();
        partitionMessageCount.computeIfAbsent(partition, k -> new AtomicLong(0)).incrementAndGet();
        actionCount.computeIfAbsent(message.getAction(), k -> new AtomicLong(0)).incrementAndGet();
        
        // Process message based on action type
        processMessage(message, partition, offset);
    }
    
    private void processMessage(UserMessage message, int partition, long offset) {
        try {
            switch (message.getAction().toUpperCase()) {
                case "CREATE":
                    logger.info("➕ Processing CREATE action for user: {}", message.getName());
                    break;
                case "UPDATE":
                    logger.info("✏️ Processing UPDATE action for user: {}", message.getName());
                    break;
                case "DELETE":
                    logger.info("❌ Processing DELETE action for user: {}", message.getName());
                    break;
                default:
                    logger.info("🔄 Processing {} action for user: {}", message.getAction(), message.getName());
                    break;
            }
            
            // Simulate processing time
            Thread.sleep(100);
            
            logger.info("✅ Successfully processed message {} from partition {} at offset {}", 
                message.getId(), partition, offset);
                
        } catch (Exception e) {
            logger.error("❌ Error processing message {} from partition {} at offset {}: {}", 
                message.getId(), partition, offset, e.getMessage());
        }
    }
    
    public Map<String, Object> getStatistics() {
        Map<String, Object> stats = new ConcurrentHashMap<>();
        stats.put("totalMessagesReceived", totalMessagesReceived.get());
        stats.put("partitionMessageCount", partitionMessageCount);
        stats.put("actionCount", actionCount);
        return stats;
    }
    
    public void resetStatistics() {
        totalMessagesReceived.set(0);
        partitionMessageCount.clear();
        actionCount.clear();
        logger.info("🗺 Statistics reset");
    }
}