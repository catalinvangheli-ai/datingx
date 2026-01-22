# 🚀 DatingX - Setup Complete Guide

## 📋 Overview

Backend complet implementat cu:
- ✅ Node.js + Express API
- ✅ MongoDB pentru baza de date
- ✅ Cloudinary pentru imagini
- ✅ JWT Authentication
- ✅ Flutter app conectat la API

---

## 🔧 Setup Rapid (3 pași)

### **Pasul 1: MongoDB Setup** (5 minute)

1. Mergi pe [mongodb.com/cloud/atlas](https://www.mongodb.com/cloud/atlas)
2. Sign up gratuit
3. **Create Cluster** → Selectează Free Tier (M0)
4. Alege region: **AWS / Frankfurt** (cel mai aproape de România)
5. Click **Create Cluster** (durează ~5 min)

După ce cluster-ul este ready:

1. **Security → Database Access**
   - Click **Add New Database User**
   - Username: `datingx_user`
   - Password: Generează automat (COPIAZĂ-L!)
   - Built-in Role: `Read and write to any database`
   - **Add User**

2. **Security → Network Access**
   - Click **Add IP Address**
   - **Allow Access from Anywhere** → `0.0.0.0/0`
   - Click **Confirm**

3. **Databases → Connect**
   - Click **Connect your application**
   - Driver: **Node.js** / Version: **5.5 or later**
   - Copiază connection string:
   ```
   mongodb+srv://datingx_user:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
   - Înlocuiește `<password>` cu parola copiată mai sus

---

### **Pasul 2: Cloudinary Setup** (3 minute)

1. Mergi pe [cloudinary.com](https://cloudinary.com/users/register_free)
2. Sign up gratuit (Free: 25GB storage, 25GB bandwidth/lună)
3. După login, mergi la **Dashboard**
4. Găsești informațiile:
   - **Cloud Name**: `dxxxxxxx`
   - **API Key**: `123456789012345`
   - **API Secret**: Click **👁️ Show** pentru a vedea

COPIAZĂ aceste 3 valori!

---

### **Pasul 3: Railway Deploy** (5 minute)

1. **Sign up pe Railway**
   - Mergi pe [railway.app](https://railway.app)
   - Click **Login with GitHub**
   - Autorizează Railway

2. **Deploy Backend**
   ```powershell
   cd C:\Users\hp\Documents\DatingX\backend
   
   # Instalează Railway CLI
   npm install -g @railway/cli
   
   # Login
   railway login
   
   # Creează proiect nou
   railway init
   # Alege: Create new project → Nume: datingx-backend
   
   # Deploy
   railway up
   ```

3. **Adaugă variabilele de mediu**
   
   Pe [railway.app](https://railway.app) dashboard:
   - Click pe proiectul tău
   - **Variables** → **New Variable**
   
   Adaugă următoarele:
   
   ```env
   MONGODB_URI=mongodb+srv://datingx_user:PASSWORD_TAU@cluster0.xxxxx.mongodb.net/datingx?retryWrites=true&w=majority
   JWT_SECRET=super-secret-key-schimba-asta-cu-ceva-random-si-lung
   CLOUDINARY_CLOUD_NAME=dxxxxxxx
   CLOUDINARY_API_KEY=123456789012345
   CLOUDINARY_API_SECRET=secretul_tau_cloudinary
   PORT=5000
   NODE_ENV=production
   FRONTEND_URL=http://localhost:3000
   ```
   
   **IMPORTANT**: Înlocuiește cu valorile tale reale!

4. **Obține URL-ul API**
   - În Railway dashboard, vei vedea **Domain** generat automat
   - Va fi ceva de genul: `https://datingx-backend-production.up.railway.app`
   - **COPIAZĂ acest URL!**

5. **Actualizează Flutter app**
   
   Editează [lib/config/api_config.dart](lib/config/api_config.dart):
   
   ```dart
   class ApiConfig {
     // Înlocuiește cu URL-ul tău Railway
     static const String baseUrl = 'https://datingx-backend-production.up.railway.app/api';
     // ...
   ```

---

## 🧪 Testare Backend

### Test Local (Optional)

1. **Creează fișierul `.env`**
   ```powershell
   cd C:\Users\hp\Documents\DatingX\backend
   Copy-Item .env.example .env
   ```

2. **Editează `.env`** cu valorile tale (MongoDB, Cloudinary)

3. **Pornește serverul**
   ```powershell
   npm start
   # Sau pentru development:
   npm run dev
   ```

4. **Test API**
   ```powershell
   # Health check
   curl http://localhost:5000/api/health
   
   # Output așteptat:
   # {"status":"OK","message":"DatingX API is running"}
   ```

### Test Production (După deploy Railway)

```powershell
# Înlocuiește cu URL-ul tău Railway
curl https://datingx-backend-production.up.railway.app/api/health
```

---

## 📱 Rebuild Flutter App

După ce actualizezi `api_config.dart` cu URL-ul Railway:

```powershell
cd C:\Users\hp\Documents\DatingX

# Clean build anterior
flutter clean

# Rebuild cu noul API URL
flutter build web --release

# Pornește server local
dart pub global run dhttpd --path=build\web --port=3000
```

Accesează: http://localhost:3000

---

## 🎯 Workflow Complet

### 1. **Register/Login**
   - User completează email + parolă
   - Flutter trimite la `POST /api/auth/register`
   - Backend creează user în MongoDB
   - Returnează JWT token
   - Flutter salvează token local

### 2. **Complete Profile (7 steps)**
   - User completează fiecare ecran
   - Date stocate temporar în `UserProvider`

### 3. **Upload Photos**
   - User selectează imagini
   - Flutter trimite la `POST /api/photo/upload`
   - Backend uploadează la Cloudinary
   - Returnează URL-ul imaginii
   - Flutter afișează imagine de la Cloudinary

### 4. **Save Profile**
   - După ultimul pas (Partner Criteria)
   - Flutter trimite tot profilul la `POST /api/profile`
   - Backend salvează în MongoDB
   - Success!

### 5. **Edit Profile**
   - User accesează profilul din AppBar
   - Flutter încarcă de la `GET /api/profile`
   - User editează și salvează
   - Flutter trimite la `POST /api/profile`

### 6. **Delete Account**
   - User apasă "Șterge Cont Permanent"
   - Flutter trimite la `DELETE /api/auth/account`
   - Backend șterge user + profil + imagini din Cloudinary
   - Flutter face logout automat

---

## 📊 API Endpoints Reference

### **Authentication**
- `POST /api/auth/register` - Înregistrare
- `POST /api/auth/login` - Autentificare
- `GET /api/auth/me` - User curent
- `DELETE /api/auth/account` - Șterge cont

### **Profile**
- `GET /api/profile` - Obține profil
- `POST /api/profile` - Salvează/actualizează profil
- `DELETE /api/profile` - Șterge profil
- `GET /api/profile/matches` - Obține match-uri

### **Photos**
- `POST /api/photo/upload` - Upload imagine
- `DELETE /api/photo/:cloudinaryId` - Șterge imagine

**Headers necesare** (toate endpoint-urile în afară de register/login):
```
Authorization: Bearer {token}
Content-Type: application/json
```

---

## 🔐 Securitate

✅ Passwords hash-uite cu bcryptjs (10 salt rounds)
✅ JWT tokens expiră în 30 zile
✅ CORS configurat (doar frontend-ul tău)
✅ Input validation cu express-validator
✅ File size limit: 5MB per image
✅ Max 6 photos per profile

---

## 📈 Next Steps

După setup complet:

1. **GitHub CI/CD**
   - Push backend în repo GitHub
   - Railway auto-deploy la fiecare push

2. **Custom Domain**
   - În Railway: Settings → Domains → Add Custom Domain
   - Exemplu: `api.datingx.ro`

3. **Monitoring**
   - Railway oferă logs automat
   - Dashboard → Deployments → View Logs

4. **Scaling**
   - Railway free tier: 500 ore/lună, 512MB RAM
   - Pentru mai mult: Railway Pro ($20/lună)

5. **Production Features**
   - Rate limiting (prevent abuse)
   - Email verification
   - Password reset
   - Image optimization
   - Caching cu Redis

---

## 🆘 Troubleshooting

### **Error: Cannot connect to MongoDB**
- Verifică Network Access în MongoDB Atlas (0.0.0.0/0)
- Verifică parola în connection string (fără `<>`)
- Verifică Database Access (user există și are permisiuni)

### **Error: Cloudinary upload failed**
- Verifică Cloud Name, API Key, API Secret
- Verifică dimensiunea imaginii (<5MB)
- Verifică formatul (PNG, JPG, JPEG)

### **Error: 401 Unauthorized**
- Token expirat → fa login din nou
- Token lipsă → verifică că ai setat token după login
- Token invalid → verifică JWT_SECRET în Railway

### **Error: CORS**
- Actualizează FRONTEND_URL în Railway variabile
- Asigură-te că URL-ul Flutter app este exact cel setat

### **Railway deploy failed**
- Verifică logs în Railway dashboard
- Asigură-te că toate variabilele de mediu sunt setate
- Verifică că `package.json` există în root folder backend

---

## 💰 Costuri (Free Tier)

| Service | Free Tier | Limite |
|---------|-----------|--------|
| **MongoDB Atlas** | FREE | 512MB storage, Shared RAM |
| **Cloudinary** | FREE | 25GB storage, 25GB bandwidth/lună |
| **Railway** | $5 credit/lună | 500 ore runtime, 512MB RAM |
| **GitHub** | FREE | Public repos unlimited |
| **TOTAL** | **$0/lună** | Perfect pentru development |

---

## 📞 Contact & Support

Pentru probleme:
1. Verifică logs în Railway: `railway logs`
2. Test endpoint: `curl https://your-api.railway.app/api/health`
3. Verifică MongoDB connection în Railway logs

---

## ✅ Checklist Final

După completarea setup-ului:

- [ ] MongoDB cluster creat și configurat
- [ ] Cloudinary account creat, credentials copiate
- [ ] Railway account creat cu GitHub
- [ ] Backend deployed pe Railway
- [ ] Toate variabilele de mediu setate în Railway
- [ ] URL Railway adăugat în `api_config.dart`
- [ ] Flutter app rebuilt cu `flutter build web`
- [ ] Test endpoint health check (succes)
- [ ] Test register + login (succes)
- [ ] Test photo upload (succes)
- [ ] Test profile save/load (succes)

**FELICITĂRI! Backend-ul este LIVE! 🎉**
