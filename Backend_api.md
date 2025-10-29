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

## Agent API Endpoints

### Get All Agents
```bash
curl -X GET http://localhost:8080/api/agents
```

### Get Agent by ID
```bash
curl -X GET http://localhost:8080/api/agents/1
```

### Create Agent (JSON)
```bash
curl -X POST http://localhost:8080/api/agents \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Agent",
    "phone": "09992315678",
    "email": "johnaaa@example.com",
    "zila": "Dhaka",
    "village": "Mirpur",
    "nidCard": "9834567890123",
    "nominee": "Jane Doe",
    "role": "Agent",
    "status": "Active"
  }'
```

### Create Agent with Photo (Multipart)
```bash
curl -X POST http://localhost:8080/api/agents/with-photo \
  -F "agent={\"name\": \"Johnd Agent\", \"phone\": \"01112315678\", \"email\": \"johnxxx@example.com\", \"zila\": \"Dhaka\", \"village\": \"Mirpur\", \"nidCard\": \"1234567890023\", \"nominee\": \"Jane Doe\", \"role\": \"Agent\", \"status\": \"Active\"};type=application/json" \
  -F "photo=@/home/mahady-hasan-fahim/Pictures/fun.jpeg"
```

### Update Agent Photo Only
```bash
curl -X POST http://localhost:8080/api/agents/1/photo \
  -F "photo=@/home/mahady-hasan-fahim/Pictures/1.png"
```

### Update Agent with New Photo (Multipart)
```bash
curl -X PUT http://localhost:8080/api/agents/1/with-photo \
  -F "agent={\"name\": \"John Updated\", \"phone\": \"01712315678\", \"email\": \"johnup@example.com\", \"zila\": \"Dhaka\", \"village\": \"Mirpur\", \"nidCard\": \"123456789000\", \"nominee\": \"Jane Doe\", \"role\": \"Agent\", \"status\": \"Active\"};type=application/json" \
  -F "photo=@/home/mahady-hasan-fahim/Pictures/1.png"
```

### Update Agent (JSON)
```bash
curl -X PUT http://localhost:8080/api/agents/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Agent Updated",
    "phone": "01712345679",
    "email": "john.updated@example.com",
    "zila": "Dhaka",
    "village": "Uttara",
    "nidCard": "1234567890123",
    "nominee": "Jane Smith",
    "role": "Senior Agent",
    "status": "Active"
  }'
```

### Get Agents by Status
```bash
curl -X GET http://localhost:8080/api/agents/status/Active
```

```bash
curl -X GET http://localhost:8080/api/agents/status/Inactive
```

### Update Agent Status Only
```bash
curl -X PUT "http://localhost:8080/api/agents/1/status?status=Inactive"
```

```bash
curl -X PUT "http://localhost:8080/api/agents/1/status?status=Suspended"
```

### Get Deleted Agents (Deletion History)
```bash
curl -X GET http://localhost:8080/api/agents/deleted
```

### Delete Agent
```bash
curl -X DELETE http://localhost:8080/api/agents/1
```

## Testing Notes

### Prerequisites
- Ensure the server is running on `http://localhost:8080`
- Replace file paths with actual image paths on your system
- Use existing IDs for products, members, and agents
- Phone numbers and NID cards must be unique

### Common Response Codes
- `200 OK` - Successful GET/PUT requests
- `201 Created` - Successful POST requests
- `204 No Content` - Successful DELETE requests
- `404 Not Found` - Resource doesn't exist
- `400 Bad Request` - Invalid input data
- `409 Conflict` - Duplicate phone or NID card

### Tips
1. Always check existing resources before updating or deleting
2. Use the GET endpoints to verify data before making changes
3. For image operations, ensure the file paths are correct and accessible
4. Test error scenarios with invalid IDs or malformed JSON
5. Phone numbers and NID cards must be unique across all agents
6. Use multipart/form-data for image uploads, application/json for regular data

### File Path Examples
Replace with your actual file paths:
- `/home/mahady-hasan-fahim/Pictures/1.png`
- `/home/mahady-hasan-fahim/Pictures/fun.jpeg`
- `/home/mahady-hasan-fahim/Pictures/agent-photo.jpg`

### Agent Status Values
- `Active` - Agent is active and working
- `Inactive` - Agent is temporarily inactive
- `Suspended` - Agent is suspended

Save this as `api-testing.md` for future reference!