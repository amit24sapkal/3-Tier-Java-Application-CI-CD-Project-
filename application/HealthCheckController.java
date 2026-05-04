package com.ekart.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class HealthCheckController {
    
    @GetMapping("/health")
    public HealthResponse health() {
        return new HealthResponse("Application is healthy", 200);
    }
    
    @GetMapping("/info")
    public AppInfo getAppInfo() {
        return new AppInfo(
            "Ekart Application",
            "1.0.0",
            "3-Tier Java Application with CI/CD"
        );
    }
    
    static class HealthResponse {
        public String message;
        public int status;
        
        public HealthResponse(String message, int status) {
            this.message = message;
            this.status = status;
        }
    }
    
    static class AppInfo {
        public String name;
        public String version;
        public String description;
        
        public AppInfo(String name, String version, String description) {
            this.name = name;
            this.version = version;
            this.description = description;
        }
    }
}
