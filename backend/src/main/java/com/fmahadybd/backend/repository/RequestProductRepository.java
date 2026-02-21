package com.fmahadybd.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.fmahadybd.backend.entity.RequestProduct;

@Repository
public interface RequestProductRepository extends JpaRepository<RequestProduct, Long> {
}