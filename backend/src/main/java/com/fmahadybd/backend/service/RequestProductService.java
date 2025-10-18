package com.fmahadybd.backend.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.fmahadybd.backend.entity.RequestProduct;
import com.fmahadybd.backend.repository.RequestProductRepository;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RequestProductService {

    private final RequestProductRepository requestProductRepository;

    public RequestProduct saveRequest(RequestProduct requestProduct) {
        return requestProductRepository.save(requestProduct);
    }

    public List<RequestProduct> getAllRequests() {
        return requestProductRepository.findAll();
    }

    public Optional<RequestProduct> getRequestById(Long id) {
        return requestProductRepository.findById(id);
    }

    public void deleteRequest(Long id) {
        requestProductRepository.deleteById(id);
    }
}