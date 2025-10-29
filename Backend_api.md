# API Testing with cURL

## Installment API Endpoints

### Get All Installments
```bash
curl -X GET http://localhost:8080/api/installments
```

### Get Installment by ID
```bash
curl -X GET http://localhost:8080/api/installments/5 \
  -H "Accept: application/json"
```

### Create Installment (JSON)
```bash
curl -X POST http://localhost:8080/api/installments \
  -H "Content-Type: application/json" \
  -d '{
    "product": {"id": 1},
    "member": {"id": 1},
    "totalAmountOfProduct": 1000.00,
    "otherCost": 50.00,
    "advanced_paid": 200.00,
    "installmentMonths": 12,
    "interestRate": 15.0,
    "status": "PENDING",
    "given_product_agent": {"id": 1}
  }'
```

### Create Installment with Images (Multipart)
```bash
curl -X POST http://localhost:8080/api/installments/with-images \
  -F "installment={\"product\": {\"id\": 1}, \"member\": {\"id\": 1}, \"totalAmountOfProduct\": 1000.00, \"otherCost\": 0.00, \"advanced_paid\": 0.00, \"installmentMonths\": 12, \"interestRate\": 15.0, \"status\": \"PENDING\", \"given_product_agent\": {\"id\": 1}};type=application/json" \
  -F "images=@/home/mahady-hasan-fahim/Pictures/1.png" \
  -F "images=@/home/mahady-hasan-fahim/Pictures/fun.jpeg"
```

### Upload Images to Existing Installment
```bash
curl -X POST http://localhost:8080/api/installments/6/images \
  -F "images=@/home/mahady-hasan-fahim/Pictures/1.png" \
  -F "images=@/home/mahady-hasan-fahim/Pictures/fun.jpeg"
```

### Update Installment (Partial Update)
```bash
curl -X PUT http://localhost:8080/api/installments/5 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "ACTIVE"
  }'
```

### Update Installment (Full Update)
```bash
curl -X PUT http://localhost:8080/api/installments/5 \
  -H "Content-Type: application/json" \
  -d '{
    "product": {"id": 1},
    "member": {"id": 1},
    "totalAmountOfProduct": 1200.00,
    "otherCost": 100.00,
    "advanced_paid": 300.00,
    "installmentMonths": 24,
    "interestRate": 12.0,
    "status": "ACTIVE",
    "given_product_agent": {"id": 1}
  }'
```

### Delete Installment
```bash
curl -X DELETE http://localhost:8080/api/installments/6
```

### Get Installment Images
```bash
curl -X GET http://localhost:8080/api/installments/5/images
```

## Testing Notes

### Prerequisites
- Ensure the server is running on `http://localhost:8080`
- Replace file paths with actual image paths on your system
- Use existing IDs for products, members, and agents

### Common Response Codes
- `200 OK` - Successful GET/PUT requests
- `201 Created` - Successful POST requests
- `204 No Content` - Successful DELETE requests
- `404 Not Found` - Resource doesn't exist
- `400 Bad Request` - Invalid input data

### Tips
1. Always check existing resources before updating or deleting
2. Use the GET endpoints to verify data before making changes
3. For image operations, ensure the file paths are correct and accessible
4. Test error scenarios with invalid IDs or malformed JSON

Save this as `api-testing.md` for future reference!