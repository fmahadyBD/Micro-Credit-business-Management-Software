package com.fmahadybd.backend.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

// @RestControllerAdvice
// public class GlobalExceptionHandler {

//     @ExceptionHandler(ResourceNotFoundException.class)
//     public ResponseEntity<ErrorResponse> handleResourceNotFound(ResourceNotFoundException ex) {
//         ErrorResponse error = new ErrorResponse("NOT_FOUND", ex.getMessage());
//         return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
//     }

//     @ExceptionHandler(IllegalArgumentException.class)
//     public ResponseEntity<ErrorResponse> handleIllegalArgument(IllegalArgumentException ex) {
//         ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", ex.getMessage());
//         return ResponseEntity.badRequest().body(error);
//     }

//     @ExceptionHandler(Exception.class)
//     public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
//         ErrorResponse error = new ErrorResponse("INTERNAL_SERVER_ERROR", "An unexpected error occurred");
//         return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
//     }

//     public static class ResourceNotFoundException extends RuntimeException {
//         public ResourceNotFoundException(String message) {
//             super(message);
//         }
//     }

//     public static class ErrorResponse {
//         private String error;
//         private String message;
//         private long timestamp;

//         public ErrorResponse(String error, String message) {
//             this.error = error;
//             this.message = message;
//             this.timestamp = System.currentTimeMillis();
//         }

//         // Getters and setters
//         public String getError() { return error; }
//         public void setError(String error) { this.error = error; }
//         public String getMessage() { return message; }
//         public void setMessage(String message) { this.message = message; }
//         public long getTimestamp() { return timestamp; }
//         public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
//     }
// }