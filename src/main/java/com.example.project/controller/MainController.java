package com.example.project.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ClassPathResource;

@Controller
public class MainController {

    @GetMapping("/src/main/resources/static/index.html")
    @ResponseBody
    public String home() {
        return "index";
    }

    @GetMapping("/resource")
    public Resource getResource() {
        return new ClassPathResource("example.txt");
    }
}
