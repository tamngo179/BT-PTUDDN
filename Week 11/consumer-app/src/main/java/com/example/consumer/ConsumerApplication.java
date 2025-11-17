package com.example.consumer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ConsumerApplication {

	public static void main(String[] args) {
		SpringApplication.run(ConsumerApplication.class, args);
		System.out.println("\n" +
				"=================================================\n" +
				"📡 KAFKA CONSUMER APP STARTED\n" +
				"🎙️ Listening on topic: user-events\n" +
				"📊 Health check: http://localhost:8082/api/health\n" +
				"📈 Statistics: http://localhost:8082/api/stats\n" +
				"=================================================\n");
	}
}