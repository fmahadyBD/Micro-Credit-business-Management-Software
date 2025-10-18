package com.fmahadybd.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.fmahadybd.backend.entity.RequestProduct;
import com.fmahadybd.backend.service.RequestProductService;

import java.util.List;

@RestController
@RequestMapping("/api/request-products")
@RequiredArgsConstructor
public class RequestProductController {

    private final RequestProductService requestProductService;

    @PostMapping
    public ResponseEntity<RequestProduct> createRequest(@RequestBody RequestProduct requestProduct) {
        return ResponseEntity.ok(requestProductService.saveRequest(requestProduct));
    }

    @GetMapping
    public ResponseEntity<List<RequestProduct>> getAllRequests() {
        return ResponseEntity.ok(requestProductService.getAllRequests());
    }

    @GetMapping("/{id}")
    public ResponseEntity<RequestProduct> getRequestById(@PathVariable Long id) {
        return requestProductService.getRequestById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRequest(@PathVariable Long id) {
        requestProductService.deleteRequest(id);
        return ResponseEntity.noContent().build();
    }
}