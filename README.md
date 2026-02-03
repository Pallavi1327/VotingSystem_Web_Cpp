Online Voting System (C++ Backend + Web Frontend)

An Online Voting System project built using a **C++ backend server** and a **web-based frontend**.  
Supports **Admin Login**, **Voter Login**, **Candidate Listing**, **Voting**, **Vote Counting**, and **Result Declaration**.

---

## 🚀 Features

### 👤 Admin Module
- Admin login
- Add candidates
- View candidate list
- View vote count
- Declare winner

### 🗳️ Voter Module
- Voter login
- View candidates
- Cast vote (only once per voter)
- Votes stored in files

---

## 🛠️ Tech Stack
- **Backend:** C++ (HTTP server using `httplib`)
- **Data Format:** JSON (`nlohmann/json`)
- **Frontend:** HTML, CSS, JavaScript
- **Storage:** Text files (candidates, voters, votes)

---

## 📁 Project Structure

VotingSystem_Web_Cpp/
│
├── Backend/
│ ├── main.cpp
│ ├── httplib.h
│ ├── json.hpp
│ ├── candidates.txt
│ ├── voters.txt
│ └── votes.txt
│
└── Frontend/
├── login.html
├── admin.html
├── voter.html
├── style.css
└── app.js


---

## ✅ How to Run Locally

### 1️⃣ Run Backend (C++ Server)
Open terminal in:

Backend/


Compile:

```bash
g++ main.cpp -o server.exe -std=c++17 -pthread -lws2_32
Run:

./server.exe
Backend starts at:

http://localhost:8080
2️⃣ Run Frontend
Open:

Frontend/login.html
✅ Recommended: use VS Code Live Server Extension for better output.

🔐 Default Credentials
Admin Login
Username: admin

Password: admin123

Sample Voter Logins (from voters.txt)
Example:

1001 / pass123

1002 / hello456

1003 / test789

🌐 Hosting
✅ Frontend can be hosted using GitHub Pages.
⚠️ Backend runs locally (C++ server) unless deployed to a VPS.

👩‍💻 Author
Pallavi Chendake
GitHub: https://github.com/Pallavi1327
