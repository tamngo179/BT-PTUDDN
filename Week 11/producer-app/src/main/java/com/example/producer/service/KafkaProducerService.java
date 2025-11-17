package com.example.producer.service;

import com.example.producer.model.UserMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class KafkaProducerService {

    private static final Logger logger = LoggerFactory.getLogger(KafkaProducerService.class);

    @Autowired
    private KafkaTemplate<String, UserMessage> kafkaTemplate;

    @Value("${app.kafka.topic.name}")
    private String topicName;

    public void sendMessage(UserMessage message) {
        logger.info("📤 Sending message to topic '{}': {}", topicName, message);
        
        CompletableFuture<SendResult<String, UserMessage>> future = 
            kafkaTemplate.send(topicName, message.getId(), message);
            
        future.whenComplete((result, exception) -> {
            if (exception == null) {
                logger.info("✅ Message sent successfully: {} with offset: {}", 
                    message.getId(), result.getRecordMetadata().offset());
            } else {
                logger.error("❌ Failed to send message: {}", message.getId(), exception);
            }
        });
    }

    public void sendMessageToPartition(UserMessage message, int partition) {
        logger.info("📤 Sending message to topic '{}' partition {}: {}", topicName, partition, message);
        
        CompletableFuture<SendResult<String, UserMessage>> future = 
            kafkaTemplate.send(topicName, partition, message.getId(), message);
            
        future.whenComplete((result, exception) -> {
            if (exception == null) {
                logger.info("✅ Message sent to partition {} successfully: {} with offset: {}", 
                    partition, message.getId(), result.getRecordMetadata().offset());
            } else {
                logger.error("❌ Failed to send message to partition {}: {}", partition, message.getId(), exception);
            }
        });
    }
}