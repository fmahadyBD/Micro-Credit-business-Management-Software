package com.fmahadybd.backend.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fmahadybd.backend.entity.DeletedMember;
import com.fmahadybd.backend.entity.Member;
import com.fmahadybd.backend.service.FileStorageService;
import com.fmahadybd.backend.service.MemberService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/members")
@Tag(name = "members")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;
    private final FileStorageService fileStorageService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    /** Create new member with mandatory images */
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Create new member with images (all images mandatory)")
    public ResponseEntity<Map<String, Object>> createMemberWithImages(
            @RequestParam("member") String memberJson,
            @RequestPart("nidCardImage") MultipartFile nidCardImage,
            @RequestPart("photo") MultipartFile photo,
            @RequestPart("nomineeNidCardImage") MultipartFile nomineeNidCardImage) {

        Map<String, Object> response = new HashMap<>();
        try {
            Member member = objectMapper.readValue(memberJson, Member.class);

            if (nidCardImage.isEmpty() || photo.isEmpty() || nomineeNidCardImage.isEmpty()) {
                response.put("success", false);
                response.put("message", "All three images are required.");
                return ResponseEntity.badRequest().body(response);
            }

            Member savedMember = memberService.saveMemberWithImages(member, nidCardImage, photo, nomineeNidCardImage);
            response.put("success", true);
            response.put("message", "Member created successfully!");
            response.put("member", savedMember);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /** Get all members */
    @GetMapping
    @Operation(summary = "Get all members")
    public ResponseEntity<List<Member>> getAllMembers() {
        return ResponseEntity.ok(memberService.getAllMembers());
    }

    /** Get member by ID using orElseThrow */
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

    /** Update member with optional images */
    @PutMapping(value = "/{id}/with-images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Update existing member with optional images")
    public ResponseEntity<Map<String, Object>> updateMemberWithImages(
            @PathVariable Long id,
            @RequestParam("member") String memberJson,
            @RequestPart(value = "nidCardImage", required = false) MultipartFile nidCardImage,
            @RequestPart(value = "photo", required = false) MultipartFile photo,
            @RequestPart(value = "nomineeNidCardImage", required = false) MultipartFile nomineeNidCardImage) {

        Map<String, Object> response = new HashMap<>();
        try {
            Member updatedMember = objectMapper.readValue(memberJson, Member.class);
            Member savedMember = memberService.updateMemberWithImages(id, updatedMember, nidCardImage, photo,
                    nomineeNidCardImage);

            response.put("success", true);
            response.put("message", "Member updated successfully!");
            response.put("member", savedMember);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Error updating member: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /** Delete member and remove images from disk */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete member by ID (moves to deleted_members and deletes images)")
    public ResponseEntity<Map<String, Object>> deleteMember(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();
        try {
            Member member = memberService.getMemberById(id)
                    .orElseThrow(() -> new RuntimeException("Member not found with ID: " + id));

            // Delete images from disk
            if (member.getPhotoPath() != null)
                fileStorageService.deleteFile(member.getPhotoPath());
            if (member.getNidCardImagePath() != null)
                fileStorageService.deleteFile(member.getNidCardImagePath());
            if (member.getNomineeNidCardImagePath() != null)
                fileStorageService.deleteFile(member.getNomineeNidCardImagePath());

            memberService.deleteMember(id);
            return ResponseEntity.ok(createSuccessResponse("Member deleted successfully", id));

        } catch (RuntimeException e) {
            return ResponseEntity.status(404).body(createErrorResponse(e.getMessage()));
        }
    }

    /** Get all deleted members */
    @GetMapping("/deleted")
    @Operation(summary = "Get all deleted members")
    public ResponseEntity<List<DeletedMember>> getDeletedMembers() {
        return ResponseEntity.ok(memberService.getAllDeletedMembers());
    }

    /** Helper methods */
    private Map<String, Object> createErrorResponse(String message) {
        Map<String, Object> resp = new HashMap<>();
        resp.put("success", false);
        resp.put("message", message);
        return resp;
    }

    private Map<String, Object> createSuccessResponse(String message, Long id) {
        Map<String, Object> resp = new HashMap<>();
        resp.put("success", true);
        resp.put("message", message);
        resp.put("id", id);
        return resp;
    }
}
