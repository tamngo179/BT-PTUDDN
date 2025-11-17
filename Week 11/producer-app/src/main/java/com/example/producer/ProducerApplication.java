package com.example.producer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ProducerApplication {

	public static void main(String[] args) {
		SpringApplication.run(ProducerApplication.class, args);
		System.out.println("\n" +
				"=================================================\n" +
				"🚀 KAFKA PRODUCER APP STARTED\n" +
				"📡 REST API: http://localhost:8081\n" +
				"📝 Send message: POST /api/messages\n" +
				"📊 Health check: GET /api/health\n" +
				"=================================================\n");
	}
}