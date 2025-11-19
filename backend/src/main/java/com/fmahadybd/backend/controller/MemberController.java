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
    private final ObjectMapper mapper = new ObjectMapper();

    /** Create with images */
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Create new member with mandatory images")
    public ResponseEntity<?> createMemberWithImages(
            @RequestParam("member") String json,
            @RequestPart("nidCardImage") MultipartFile nid,
            @RequestPart("photo") MultipartFile photo,
            @RequestPart("nomineeNidCardImage") MultipartFile nomineeNid) {

        try {
            Member member = mapper.readValue(json, Member.class);
            Member saved = memberService.saveMemberWithImages(member, nid, photo, nomineeNid);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Member created successfully",
                    "member", saved
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    @GetMapping
    public List<Member> getAll() {
        return memberService.getAllMembers();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Long id) {
        return memberService.getMemberById(id)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(404).body(
                        Map.of("success", false, "message", "Member not found")
                ));
    }

    /** Update with optional images */
    @PutMapping(value = "/{id}/with-images", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateMember(
            @PathVariable Long id,
            @RequestParam("member") String json,
            @RequestPart(value = "nidCardImage", required = false) MultipartFile nid,
            @RequestPart(value = "photo", required = false) MultipartFile photo,
            @RequestPart(value = "nomineeNidCardImage", required = false) MultipartFile nomineeNid) {

        try {
            Member updated = mapper.readValue(json, Member.class);
            Member saved = memberService.updateMemberWithImages(id, updated, nid, photo, nomineeNid);

            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Member updated successfully",
                    "member", saved
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    /** Delete */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id) {
        try {
            memberService.deleteMember(id);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "message", "Member deleted successfully",
                    "id", id
            ));
        } catch (Exception e) {
            return ResponseEntity.status(404).body(Map.of(
                    "success", false,
                    "message", e.getMessage()
            ));
        }
    }

    @GetMapping("/deleted")
    public List<DeletedMember> getDeleted() {
        return memberService.getAllDeletedMembers();
    }
}
