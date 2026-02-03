# VotingSystem_Web_Cpp
# Online Voting System (C++ Backend + Web Frontend)

A simple Online Voting System project with:
- C++ backend server (runs on localhost:8080)
- Web frontend (HTML/CSS/JS)
- Features: Admin login, Voter login, Candidate list, Cast vote, Vote count

## Tech Stack
- C++ (httplib)
- JSON (nlohmann/json)
- HTML, CSS, JavaScript

## Folder Structure
Frontend/ -> UI files
Backend/ -> C++ backend server + data files

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

## How to Run

### Backend
```bash
cd Backend
g++ main.cpp -o server.exe -std=c++17 -pthread -lws2_32
./server.exe

+++++++++++++++++++++++++++++++++
Backend runs on:
http://localhost:8080

Frontend

Open Frontend/login.html
(or run using VS Code Live Server)
++++++++++++++++++++++++++++++++++++
