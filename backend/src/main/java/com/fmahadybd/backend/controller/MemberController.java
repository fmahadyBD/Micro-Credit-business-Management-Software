package com.fmahadybd.backend.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fmahadybd.backend.entity.DeletedMember;
import com.fmahadybd.backend.entity.Member;
import com.fmahadybd.backend.service.MemberService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/members")
@Tag(name = "members")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @PostMapping(consumes = { MediaType.MULTIPART_FORM_DATA_VALUE }, produces = MediaType.APPLICATION_JSON_VALUE)
    @Operation(summary = "Create new member with images (all images mandatory)")
    public ResponseEntity<Map<String, Object>> createMemberWithImages(
            @RequestParam("member") String memberJson,
            @RequestPart("nidCardImage") MultipartFile nidCardImage,
            @RequestPart("photo") MultipartFile photo,
            @RequestPart("nomineeNidCardImage") MultipartFile nomineeNidCardImage) {

        Map<String, Object> response = new HashMap<>();

        try {
            // Convert JSON string into Member object
            Member member = objectMapper.readValue(memberJson, Member.class);

            // Validate required images
            if (nidCardImage.isEmpty() || photo.isEmpty() || nomineeNidCardImage.isEmpty()) {
                response.put("success", false);
                response.put("message", "All three images (NID, photo, nominee NID) are required.");
                return ResponseEntity.badRequest().body(response);
            }

            // Save member
            Member savedMember = memberService.saveMemberWithImages(member, nidCardImage, photo, nomineeNidCardImage);

            // ✅ Always return JSON with success info
            response.put("success", true);
            response.put("message", "Member created successfully!");
            response.put("member", savedMember);
            return ResponseEntity.ok(response);

        } catch (com.fasterxml.jackson.core.JsonProcessingException e) {
            response.put("success", false);
            response.put("message", "Invalid member JSON: " + e.getOriginalMessage());
            return ResponseEntity.badRequest().body(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error creating member: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

    /** ✅ Get all members */
    @GetMapping
    @Operation(summary = "Get all members")
    public ResponseEntity<List<Member>> getAllMembers() {
        return ResponseEntity.ok(memberService.getAllMembers());
    }

    /** ✅ Get member by ID */
    @GetMapping("/{id}")
    @Operation(summary = "Get member by ID")
    public ResponseEntity<?> getMemberById(@PathVariable Long id) {
        try {
            Member member = memberService.getMemberById(id)
                    .orElseThrow(() -> new RuntimeException("Member not found with ID: " + id));
            return ResponseEntity.ok(member);
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(createErrorResponse(e.getMessage()));
        }
    }

    /** ✅ Update existing member */
    @PutMapping("/{id}")
    @Operation(summary = "Update member by ID")
    public ResponseEntity<?> updateMember(@PathVariable Long id, @Valid @RequestBody Member updatedMember,
            BindingResult result) {
        if (result.hasErrors()) {
            String errorMessage = result.getAllErrors().get(0).getDefaultMessage();
            return ResponseEntity.badRequest().body(createErrorResponse(errorMessage));
        }

        try {
            Member savedMember = memberService.updateMember(id, updatedMember);
            return ResponseEntity.ok(savedMember);
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(createErrorResponse(e.getMessage()));
        }
    }

    /** ✅ Delete member by ID (moves to DeletedMember table) */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete member by ID (moves to deleted_members)")
    public ResponseEntity<Map<String, Object>> deleteMember(@PathVariable Long id) {
        try {
            memberService.deleteMember(id);
            return ResponseEntity.ok(createSuccessResponse(
                    "Member deleted and stored in DeletedMember table successfully", id));
        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(createErrorResponse(e.getMessage()));
        }
    }

    /** ✅ Get all deleted members (history) */
    @GetMapping("/deleted")
    @Operation(summary = "Get all deleted members (deletion history)")
    public ResponseEntity<List<DeletedMember>> getDeletedMembers() {
        List<DeletedMember> deletedMembers = memberService.getAllDeletedMembers();
        return ResponseEntity.ok(deletedMembers);
    }

    /** 🔧 Helper methods */
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        return response;
    }

    private Map<String, Object> createSuccessResponse(String message, Long id) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", message);
        response.put("id", id);
        return response;
    }
}
