package com.fmahadybd.backend.repository;

import com.fmahadybd.backend.entity.DeletedUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DeletedUserRepository extends JpaRepository<DeletedUser, Long> {
}
