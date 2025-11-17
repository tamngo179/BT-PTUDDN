package com.example.consumer.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

public class UserMessage {
    private String id;
    private String name;
    private String email;
    private String action;
    private String data;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime timestamp;

    public UserMessage() {
        this.timestamp = LocalDateTime.now();
    }

    public UserMessage(String id, String name, String email, String action, String data) {
        this();
        this.id = id;
        this.name = name;
        this.email = email;
        this.action = action;
        this.data = data;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getData() { return data; }
    public void setData(String data) { this.data = data; }

    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }

    @Override
    public String toString() {
        return "UserMessage{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                ", action='" + action + '\'' +
                ", data='" + data + '\'' +
                ", timestamp=" + timestamp +
                '}';
    }
}