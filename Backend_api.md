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








# 🏦 Microcredit System - Member API Documentation

## 📋 Member Management Endpoints

### 1. 📸 Create Member with Images (Multipart/form-data)
```bash
curl -X POST http://localhost:8080/api/members \
  -F "member={
    \"name\": \"John Doe\",
    \"phone\": \"01712345678\", 
    \"zila\": \"Dhaka\",
    \"village\": \"Mirpur\",
    \"nidCardNumber\": \"1234567890123\",
    \"nomineeName\": \"Jane Doe\",
    \"nomineePhone\": \"01787654321\",
    \"nomineeNidCardNumber\": \"9876543210987\",
    \"status\": \"ACTIVE\"
  }" \
  -F "nidCardImage=@/home/mahady-hasan-fahim/Pictures/1.png" \
  -F "photo=@/home/mahady-hasan-fahim/Pictures/1.png" \
  -F "nomineeNidCardImage=@/home/mahady-hasan-fahim/Pictures/1.png"
```

**Required Fields:**
- ✅ `name`: Member full name
- ✅ `phone`: Unique phone number (10-15 digits)
- ✅ `zila`: District
- ✅ `village`: Village
- ✅ `nidCardNumber`: Unique NID number
- ✅ `nomineeName`: Nominee's full name
- ✅ `nomineePhone`: Nominee's phone
- ✅ `nomineeNidCardNumber`: Nominee's NID
- ✅ `status`: ACTIVE/INACTIVE

**Required Images:**
- 📷 `nidCardImage`: Member's NID card photo
- 📷 `photo`: Member's profile photo  
- 📷 `nomineeNidCardImage`: Nominee's NID card photo

---

### 2. 📜 Get All Members
```bash
curl -X GET http://localhost:8080/api/members
```

**Response:** Returns complete member list with all installments and payment schedules.

---

### 3. 🔍 Get Member by ID
```bash
curl -X GET http://localhost:8080/api/members/1
```

**Response:** Returns detailed member information including:
- Personal details
- All linked installments
- Payment schedules
- Agent information
- File paths for images

---

### 4. ✏️ Update Member (JSON)
```bash
curl -X PUT http://localhost:8080/api/members/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Updated",
    "phone": "017123995678",
    "zila": "Dhaka",
    "village": "Mirpur",
    "nidCardNumber": "1234567xxx0123",
    "nomineeName": "Jane Updated",
    "nomineePhone": "017876x4321",
    "nomineeNidCardNumber": "98765x3210987",
    "status": "ACTIVE"
  }'
```

**⚠️ Important:** Phone and NID numbers must be unique across all members.

---

### 5. 🗑️ Delete Member
```bash
curl -X DELETE http://localhost:8080/api/members/1
```

**Features:**
- ✅ Moves member to `deleted_members` table
- ✅ Preserves all member data for history
- ✅ Maintains referential integrity

---

### 6. 📚 Get Deleted Members (History)
```bash
curl -X GET http://localhost:8080/api/members/deleted
```

**Use Case:** Audit trail and recovery reference.

---

## 🎯 Response Format

### Success Response:
```json
{
  "id": 1,
  "name": "John Doe",
  "phone": "01712345678",
  "zila": "Dhaka",
  "village": "Mirpur",
  "nidCardNumber": "1234567890123",
  "nidCardImagePath": "uploads/members/uuid_filename.png",
  "photoPath": "uploads/members/uuid_photo.png",
  "nomineeName": "Jane Doe", 
  "nomineePhone": "01787654321",
  "nomineeNidCardNumber": "9876543210987",
  "nomineeNidCardImagePath": "uploads/members/uuid_nominee.png",
  "joinDate": "2025-10-29",
  "status": "ACTIVE",
  "installments": [...]
}
```

### Error Response:
```json
{
  "success": false,
  "message": "Error description"
}
```

---

## 🔑 Key Features

- ✅ **Unique Constraints**: Phone & NID numbers are unique
- ✅ **File Upload**: Automatic image storage with UUID filenames
- ✅ **Data Integrity**: Soft delete with history preservation
- ✅ **Relationships**: Full installment and payment schedule linking
- ✅ **Validation**: Comprehensive input validation
- ✅ **Audit Trail**: Complete deletion history

---

## 💡 Pro Tips

1. **Always check unique fields** before creating/updating members
2. **Use the comprehensive GET responses** for member dashboards
3. **Deleted members are preserved** for audit purposes
4. **All images are required** for member creation
5. **Phone format**: 10-15 digits, unique across system

**Ready to manage your microcredit members!** 🚀