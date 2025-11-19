package com.fmahadybd.backend.service;

import com.fmahadybd.backend.entity.DeletedMember;
import com.fmahadybd.backend.entity.Member;
import com.fmahadybd.backend.repository.DeletedMemberRepository;
import com.fmahadybd.backend.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final DeletedMemberRepository deletedMemberRepository;
    private final FileStorageService fileStorageService;

    private final String folder = "members";

    /** Create new member with images */
    public Member saveMemberWithImages(Member member,
                                       MultipartFile nid,
                                       MultipartFile photo,
                                       MultipartFile nomineeNid) {

        member.setJoinDate(LocalDate.now());

        // FIRST SAVE → GET GENERATED ID
        Member saved = memberRepository.save(member);
        Long id = saved.getId();

        // SAVE IMAGES USING MEMBER ID
        if (nid != null && !nid.isEmpty())
            saved.setNidCardImagePath(fileStorageService.saveFile(nid, id, folder));

        if (photo != null && !photo.isEmpty())
            saved.setPhotoPath(fileStorageService.saveFile(photo, id, folder));

        if (nomineeNid != null && !nomineeNid.isEmpty())
            saved.setNomineeNidCardImagePath(fileStorageService.saveFile(nomineeNid, id, folder));

        return memberRepository.save(saved);
    }

    public List<Member> getAllMembers() {
        return memberRepository.findAll();
    }

    public Optional<Member> getMemberById(Long id) {
        return memberRepository.findById(id);
    }

    /** Update existing member + optional images */
    public Member updateMemberWithImages(Long id,
                                         Member updated,
                                         MultipartFile nid,
                                         MultipartFile photo,
                                         MultipartFile nomineeNid) {

        return memberRepository.findById(id).map(member -> {

            member.setName(updated.getName());
            member.setPhone(updated.getPhone());
            member.setZila(updated.getZila());
            member.setVillage(updated.getVillage());
            member.setNidCardNumber(updated.getNidCardNumber());
            member.setNomineeName(updated.getNomineeName());
            member.setNomineePhone(updated.getNomineePhone());
            member.setNomineeNidCardNumber(updated.getNomineeNidCardNumber());
            if (updated.getStatus() != null) member.setStatus(updated.getStatus());

            // OPTIONAL NEW IMAGES
            if (nid != null && !nid.isEmpty())
                member.setNidCardImagePath(fileStorageService.saveFile(nid, id, folder));

            if (photo != null && !photo.isEmpty())
                member.setPhotoPath(fileStorageService.saveFile(photo, id, folder));

            if (nomineeNid != null && !nomineeNid.isEmpty())
                member.setNomineeNidCardImagePath(fileStorageService.saveFile(nomineeNid, id, folder));

            return memberRepository.save(member);

        }).orElseThrow(() -> new RuntimeException("Member not found with ID " + id));
    }

    /** Delete → Move to Deleted table + delete images */
    public void deleteMember(Long id) {

        Member member = memberRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        // DELETE FILES (relative paths)
        fileStorageService.deleteFile(member.getNidCardImagePath());
        fileStorageService.deleteFile(member.getPhotoPath());
        fileStorageService.deleteFile(member.getNomineeNidCardImagePath());

        // MOVE TO deleted_members
        DeletedMember deleted = new DeletedMember();
        deleted.setOriginalMemberId(member.getId());
        deleted.setName(member.getName());
        deleted.setPhone(member.getPhone());
        deleted.setZila(member.getZila());
        deleted.setVillage(member.getVillage());
        deleted.setNidCardNumber(member.getNidCardNumber());
        deleted.setNidCardImagePath(member.getNidCardImagePath());
        deleted.setPhotoPath(member.getPhotoPath());
        deleted.setNomineeName(member.getNomineeName());
        deleted.setNomineePhone(member.getNomineePhone());
        deleted.setNomineeNidCardNumber(member.getNomineeNidCardNumber());
        deleted.setNomineeNidCardImagePath(member.getNomineeNidCardImagePath());
        deleted.setJoinDate(member.getJoinDate());
        deleted.setStatus(member.getStatus());
        deleted.setDeletedAt(LocalDateTime.now());

        deletedMemberRepository.save(deleted);

        memberRepository.delete(member);
    }

    public List<DeletedMember> getAllDeletedMembers() {
        return deletedMemberRepository.findAll();
    }
}
