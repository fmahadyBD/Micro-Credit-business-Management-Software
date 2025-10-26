package com.fmahadybd.backend.controller;

import com.fmahadybd.backend.entity.Member;
import com.fmahadybd.backend.entity.DeletedMember;
import com.fmahadybd.backend.service.MemberService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/members")
@Tag(name = "members")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    /** Create a new Member */
    @PostMapping
    @Operation(summary = "Create new member")
    public ResponseEntity<?> createMember(@Valid @RequestBody Member member, BindingResult result) {
        if (result.hasErrors()) {
            String errorMessage = result.getAllErrors().get(0).getDefaultMessage();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", errorMessage);
            return ResponseEntity.badRequest().body(errorResponse);
        }
        Member savedMember = memberService.saveMember(member);
        return ResponseEntity.ok(savedMember);
    }

    /** Get all members */
    @GetMapping
    @Operation(summary = "Get all members")
    public ResponseEntity<List<Member>> getAllMembers() {
        return ResponseEntity.ok(memberService.getAllMembers());
    }

    /** Get member by ID */
    @GetMapping("/{id}")
    @Operation(summary = "Get member by ID")
    public ResponseEntity<?> getMemberById(@PathVariable Long id) {
        try {
            Member member = memberService.getMemberById(id)
                    .orElseThrow(() -> new RuntimeException("Member not found with ID: " + id));
            return ResponseEntity.ok(member);
        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(404).body(errorResponse);
        }
    }

    /** Update existing member */
    @PutMapping("/{id}")
    @Operation(summary = "Update member by ID")
    public ResponseEntity<?> updateMember(@PathVariable Long id, @Valid @RequestBody Member updatedMember,
                                          BindingResult result) {
        if (result.hasErrors()) {
            String errorMessage = result.getAllErrors().get(0).getDefaultMessage();
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", errorMessage);
            return ResponseEntity.badRequest().body(errorResponse);
        }

        try {
            Member savedMember = memberService.updateMember(id, updatedMember);
            return ResponseEntity.ok(savedMember);
        } catch (RuntimeException e) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("message", e.getMessage());
            return ResponseEntity.status(404).body(errorResponse);
        }
    }

    /** Delete member by ID (moves to DeletedMember) */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete member by ID (moves to deleted_members)")
    public ResponseEntity<Map<String, Object>> deleteMember(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            memberService.deleteMember(id);
            response.put("success", true);
            response.put("message", "Member deleted and stored in DeletedMember table successfully");
            response.put("id", id);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(404).body(response);
        }
    }

    /** Get all deleted members (history) */
    @GetMapping("/deleted")
    @Operation(summary = "Get all deleted members (deletion history)")
    public ResponseEntity<List<DeletedMember>> getDeletedMembers() {
        List<DeletedMember> deletedMembers = memberService.getAllDeletedMembers();
        if (deletedMembers.isEmpty()) {
            return ResponseEntity.ok().body(List.of());
        }
        return ResponseEntity.ok(deletedMembers);
    }
}
