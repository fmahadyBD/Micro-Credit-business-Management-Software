package com.fmahadybd.backend.service;

import com.fmahadybd.backend.entity.DeletedMember;
import com.fmahadybd.backend.entity.Member;
import com.fmahadybd.backend.repository.DeletedMemberRepository;
import com.fmahadybd.backend.repository.MemberRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class MemberService {

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private DeletedMemberRepository deletedMemberRepository;

    @Autowired
    private FileStorageService fileStorageService;

    private String folder="members";

    /** Create a new member with images */
    public Member saveMemberWithImages(Member member,
                                       MultipartFile nidCardImage,
                                       MultipartFile photo,
                                       MultipartFile nomineeNidCardImage) {

        if (nidCardImage != null && !nidCardImage.isEmpty())
            member.setNidCardImagePath(fileStorageService.saveFile(nidCardImage, 0L,folder));

        if (photo != null && !photo.isEmpty())
            member.setPhotoPath(fileStorageService.saveFile(photo, 0L,folder));

        if (nomineeNidCardImage != null && !nomineeNidCardImage.isEmpty())
            member.setNomineeNidCardImagePath(fileStorageService.saveFile(nomineeNidCardImage, 0L,folder));

        member.setJoinDate(LocalDate.now());
        return memberRepository.save(member);
    }

    /** Get all members */
    public List<Member> getAllMembers() {
        return memberRepository.findAll();
    }

    /** Get member by ID */
    public Optional<Member> getMemberById(Long id) {
        return memberRepository.findById(id);
    }

    /** Update existing member with optional images */
    public Member updateMemberWithImages(Long id, Member updatedMember,
                                         MultipartFile nidCardImage,
                                         MultipartFile photo,
                                         MultipartFile nomineeNidCardImage) {
        return memberRepository.findById(id).map(member -> {
            member.setName(updatedMember.getName());
            member.setPhone(updatedMember.getPhone());
            member.setZila(updatedMember.getZila());
            member.setVillage(updatedMember.getVillage());
            member.setNidCardNumber(updatedMember.getNidCardNumber());
            member.setNomineeName(updatedMember.getNomineeName());
            member.setNomineePhone(updatedMember.getNomineePhone());
            member.setNomineeNidCardNumber(updatedMember.getNomineeNidCardNumber());

            if (updatedMember.getStatus() != null)
                member.setStatus(updatedMember.getStatus());

            // Optional new images
            if (nidCardImage != null && !nidCardImage.isEmpty())
                member.setNidCardImagePath(fileStorageService.saveFile(nidCardImage, id,folder));

            if (photo != null && !photo.isEmpty())
                member.setPhotoPath(fileStorageService.saveFile(photo, id,folder));

            if (nomineeNidCardImage != null && !nomineeNidCardImage.isEmpty())
                member.setNomineeNidCardImagePath(fileStorageService.saveFile(nomineeNidCardImage, id,folder));

            return memberRepository.save(member);
        }).orElseThrow(() -> new RuntimeException("Member not found with ID: " + id));
    }

    /** Delete member (with file cleanup) */
    public void deleteMember(Long id) {
        Member member = memberRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Member not found with ID: " + id));

        // Delete files
        fileStorageService.deleteFile(member.getNidCardImagePath());
        fileStorageService.deleteFile(member.getPhotoPath());
        fileStorageService.deleteFile(member.getNomineeNidCardImagePath());

        // Move to DeletedMember table
        DeletedMember deletedMember = new DeletedMember();
        deletedMember.setOriginalMemberId(member.getId());
        deletedMember.setName(member.getName());
        deletedMember.setPhone(member.getPhone());
        deletedMember.setZila(member.getZila());
        deletedMember.setVillage(member.getVillage());
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
}
