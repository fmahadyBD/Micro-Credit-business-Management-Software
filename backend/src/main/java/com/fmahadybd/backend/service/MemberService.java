package com.fmahadybd.backend.service;

import com.fmahadybd.backend.entity.Member;
import com.fmahadybd.backend.entity.DeletedMember;
import com.fmahadybd.backend.repository.MemberRepository;
import com.fmahadybd.backend.repository.DeletedMemberRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class MemberService {

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private DeletedMemberRepository deletedMemberRepository;

    private final String UPLOAD_DIR = "uploads/members/";

    /** Create a new member with images */
    public Member saveMemberWithImages(Member member, MultipartFile nidCardImage,
                                     MultipartFile photo, MultipartFile nomineeNidCardImage) {
        
        // Save images and set file paths
        if (nidCardImage != null && !nidCardImage.isEmpty()) {
            String nidImagePath = saveImage(nidCardImage);
            member.setNidCardImagePath(nidImagePath);
        }
        
        if (photo != null && !photo.isEmpty()) {
            String photoPath = saveImage(photo);
            member.setPhotoPath(photoPath);
        }
        
        if (nomineeNidCardImage != null && !nomineeNidCardImage.isEmpty()) {
            String nomineeNidImagePath = saveImage(nomineeNidCardImage);
            member.setNomineeNidCardImagePath(nomineeNidImagePath);
        }
        
        member.setJoinDate(LocalDate.now());
        return memberRepository.save(member);
    }

    /** Create member without images */
    public Member saveMember(Member member) {
        member.setJoinDate(LocalDate.now());
        return memberRepository.save(member);
    }

    /** Get all members (fixed JSON serialization) */
    public List<Member> getAllMembers() {
        return memberRepository.findAll();
    }

    /** Get member by ID */
    public Optional<Member> getMemberById(Long id) {
        return memberRepository.findById(id);
    }

    /** Update existing member */
    public Member updateMember(Long id, Member updatedMember) {
        return memberRepository.findById(id).map(member -> {
            member.setName(updatedMember.getName());
            member.setPhone(updatedMember.getPhone());
            member.setZila(updatedMember.getZila());
            member.setVillage(updatedMember.getVillage());
            member.setNidCardNumber(updatedMember.getNidCardNumber());
            member.setNomineeName(updatedMember.getNomineeName());
            member.setNomineePhone(updatedMember.getNomineePhone());
            member.setNomineeNidCardNumber(updatedMember.getNomineeNidCardNumber());
            
            // Handle status update
            if (updatedMember.getStatus() != null) {
                member.setStatus(updatedMember.getStatus());
            }

            return memberRepository.save(member);
        }).orElseThrow(() -> new RuntimeException("Member not found with ID: " + id));
    }

    /** Delete member by ID (move to DeletedMember) */
    public void deleteMember(Long id) {
        Member member = memberRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Member not found with ID: " + id));

        DeletedMember deletedMember = new DeletedMember();
        deletedMember.setOriginalMemberId(member.getId());
        deletedMember.setName(member.getName());
        deletedMember.setPhone(member.getPhone());
        deletedMember.setZila(member.getZila());
        deletedMember.setVillage(member.getVillage());
        
        // Updated fields
        deletedMember.setNidCardNumber(member.getNidCardNumber());
        deletedMember.setNidCardImagePath(member.getNidCardImagePath());
        deletedMember.setPhotoPath(member.getPhotoPath());
        deletedMember.setNomineeName(member.getNomineeName());
        deletedMember.setNomineePhone(member.getNomineePhone());
        deletedMember.setNomineeNidCardNumber(member.getNomineeNidCardNumber());
        deletedMember.setNomineeNidCardImagePath(member.getNomineeNidCardImagePath());
        deletedMember.setJoinDate(member.getJoinDate());
        deletedMember.setStatus(member.getStatus());
        deletedMember.setDeletedAt(LocalDateTime.now());

        deletedMemberRepository.save(deletedMember);
        memberRepository.deleteById(id);
    }

    /** Get all deleted members */
    public List<DeletedMember> getAllDeletedMembers() {
        return deletedMemberRepository.findAll();
    }

    /** Helper method to save images */
    private String saveImage(MultipartFile image) {
        try {
            // Create upload directory if it doesn't exist
            Path uploadPath = Paths.get(UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // Generate unique filename
            String fileName = UUID.randomUUID().toString() + "_" + image.getOriginalFilename();
            Path filePath = uploadPath.resolve(fileName);
            
            // Save file
            Files.copy(image.getInputStream(), filePath);
            
            return filePath.toString();
        } catch (IOException e) {
            throw new RuntimeException("Failed to save image: " + e.getMessage());
        }
    }
}