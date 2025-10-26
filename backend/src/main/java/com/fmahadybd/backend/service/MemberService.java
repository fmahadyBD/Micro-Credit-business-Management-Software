package com.fmahadybd.backend.service;

import com.fmahadybd.backend.entity.Member;
import com.fmahadybd.backend.entity.DeletedMember;
import com.fmahadybd.backend.repository.MemberRepository;
import com.fmahadybd.backend.repository.DeletedMemberRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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

    /** Create a new member */
    public Member saveMember(Member member) {
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

    /** Update existing member */
    public Member updateMember(Long id, Member updatedMember) {
        return memberRepository.findById(id).map(member -> {
            member.setName(updatedMember.getName());
            member.setPhone(updatedMember.getPhone());
            member.setZila(updatedMember.getZila());
            member.setVillage(updatedMember.getVillage());
            member.setNidCard(updatedMember.getNidCard());
            member.setPhoto(updatedMember.getPhoto());
            member.setNominee(updatedMember.getNominee());
            member.setAgents(updatedMember.getAgents());
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
        deletedMember.setNidCard(member.getNidCard());
        deletedMember.setPhoto(member.getPhoto());
        deletedMember.setNominee(member.getNominee());
        deletedMember.setJoinDate(member.getJoinDate());
        deletedMember.setDeletedAt(LocalDateTime.now());

        deletedMemberRepository.save(deletedMember);
        memberRepository.deleteById(id);
    }

    /** Get all deleted members */
    public List<DeletedMember> getAllDeletedMembers() {
        return deletedMemberRepository.findAll();
    }
}
