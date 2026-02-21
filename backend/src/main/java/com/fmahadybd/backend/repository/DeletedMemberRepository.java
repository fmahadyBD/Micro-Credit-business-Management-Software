package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.DeletedMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DeletedMemberRepository extends JpaRepository<DeletedMember, Long> {
}
