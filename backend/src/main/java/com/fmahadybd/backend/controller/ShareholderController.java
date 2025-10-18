package com.fmahadybd.backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.fmahadybd.backend.entity.Shareholder;
import com.fmahadybd.backend.service.ShareholderService;

import java.util.List;

@RestController
@RequestMapping("/api/shareholders")
@RequiredArgsConstructor
public class ShareholderController {

    private final ShareholderService shareholderService;

    @PostMapping
    public ResponseEntity<Shareholder> createShareholder(@RequestBody Shareholder shareholder) {
        return ResponseEntity.ok(shareholderService.saveShareholder(shareholder));
    }

    @GetMapping
    public ResponseEntity<List<Shareholder>> getAllShareholders() {
        return ResponseEntity.ok(shareholderService.getAllShareholders());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Shareholder> getShareholderById(@PathVariable Long id) {
        return shareholderService.getShareholderById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteShareholder(@PathVariable Long id) {
        shareholderService.deleteShareholder(id);
        return ResponseEntity.noContent().build();
    }
}