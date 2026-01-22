# DatingX Backend API

Backend pentru aplicația DatingX - Dating app cu compatibilitate avansată.

## Tehnologii

- **Node.js** + **Express** - Server API REST
- **MongoDB** - Baza de date NoSQL
- **Cloudinary** - Stocarea imaginilor în cloud
- **JWT** - Autentificare securizată
- **bcryptjs** - Hash-uire parole

## Setup Local

### 1. Instalează dependențele

```bash
cd backend
npm install
```

### 2. Configurează variabilele de mediu

Creează fișierul `.env` din `.env.example`:

```bash
cp .env.example .env
```

Editează `.env` și completează:

```env
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/datingx
JWT_SECRET=schimba-asta-cu-un-secret-securizat
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
PORT=5000
FRONTEND_URL=http://localhost:3000
```

### 3. Pornește serverul

**Development:**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Înregistrare utilizator
- `POST /api/auth/login` - Autentificare
- `GET /api/auth/me` - Obține utilizator curent
- `DELETE /api/auth/account` - Șterge cont

### Profile

- `GET /api/profile` - Obține profil
- `POST /api/profile` - Creează/actualizează profil
- `DELETE /api/profile` - Șterge profil
- `GET /api/profile/matches` - Obține match-uri

### Photos

- `POST /api/photo/upload` - Încarcă fotografie
- `DELETE /api/photo/:cloudinaryId` - Șterge fotografie

## Deploy pe Railway

### 1. Creează cont pe Railway.app

1. Mergi pe [railway.app](https://railway.app)
2. Sign up cu GitHub

### 2. Deploy Backend

```bash
# În directorul backend
railway login
railway init
railway up
```

### 3. Adaugă MongoDB

1. În dashboard Railway, click "New" → "Database" → "MongoDB"
2. Copiază `MONGODB_URI` din variabilele de mediu

### 4. Adaugă variabilele de mediu

În Railway dashboard, adaugă toate variabilele din `.env`:

- `MONGODB_URI` (auto-generat de Railway)
- `JWT_SECRET`
- `CLOUDINARY_CLOUD_NAME`
- `CLOUDINARY_API_KEY`
- `CLOUDINARY_API_SECRET`
- `FRONTEND_URL` (URL-ul Flutter app după deploy)

### 5. Obține URL-ul API

După deploy, Railway îți va da un URL public:
```
https://your-app-name.up.railway.app
```

Folosește acest URL în Flutter app pentru API calls.

## Configurare Cloudinary

1. Creează cont pe [cloudinary.com](https://cloudinary.com)
2. În Dashboard, găsești:
   - Cloud Name
   - API Key
   - API Secret
3. Adaugă-le în `.env`

## Configurare MongoDB Atlas (alternativă la Railway MongoDB)

1. Creează cont pe [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Creează cluster gratuit
3. Database Access → Add User
4. Network Access → Add IP (0.0.0.0/0 pentru production)
5. Connect → Connect your application → Copiază connection string
6. Înlocuiește `<password>` cu parola userului

## Structura Proiectului

```
backend/
├── config/
│   └── cloudinary.js      # Configurare Cloudinary
├── middleware/
│   └── auth.js             # JWT authentication
├── models/
│   ├── User.js             # Model utilizator
│   └── Profile.js          # Model profil
├── routes/
│   ├── auth.js             # Rute autentificare
│   ├── profile.js          # Rute profil
│   └── photo.js            # Rute fotografii
├── .env.example            # Template variabile mediu
├── .gitignore
├── package.json
├── railway.json            # Config Railway
└── server.js               # Entry point
```

## Testing

Test endpoint-urile cu curl:

```bash
# Health check
curl http://localhost:5000/api/health

# Register
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

## Securitate

- ✅ Passwords hash-uite cu bcryptjs
- ✅ JWT pentru autentificare
- ✅ CORS configurat
- ✅ Validare input cu express-validator
- ✅ Rate limiting (de implementat)
- ✅ Helmet pentru headers securizați (de implementat)

## Next Steps

După configurare:
1. Testează toate endpoint-urile
2. Deploy pe Railway
3. Actualizează Flutter app să folosească API-ul
4. Configurează CI/CD cu GitHub Actions
