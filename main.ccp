#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>

#include "httplib.h"
#include "json.hpp"

using namespace std;
using json = nlohmann::json;

struct Candidate {
    int id;
    string name;
};

// ---------- File Helpers ----------
vector<Candidate> loadCandidates() {
    vector<Candidate> candidates;
    ifstream fin("candidates.txt");
    Candidate c;
    while (fin >> c.id >> c.name) {
        candidates.push_back(c);
    }
    return candidates;
}

bool voterLogin(const string &voterId, const string &pass) {
    ifstream fin("voters.txt");
    if (!fin.is_open()) return false;

    string id, password;
    while (fin >> id >> password) {
        if (id == voterId && password == pass) return true;
    }
    return false;
}

bool isValidCandidate(int cid) {
    auto candidates = loadCandidates();
    for (auto &c : candidates) {
        if (c.id == cid) return true;
    }
    return false;
}

bool hasVoted(const string &voterId) {
    ifstream fin("votes.txt");
    if (!fin.is_open()) return false;

    string id;
    int cid;
    while (fin >> id >> cid) {
        if (id == voterId) return true;
    }
    return false;
}

bool saveVote(const string &voterId, int candidateId) {
    ofstream fout("votes.txt", ios::app);
    if (!fout.is_open()) return false;
    fout << voterId << " " << candidateId << "\n";
    return true;
}

map<int, int> getVoteCount() {
    map<int, int> count;
    ifstream fin("votes.txt");
    if (!fin.is_open()) return count;

    string voterId;
    int cid;
    while (fin >> voterId >> cid) {
        count[cid]++;
    }
    return count;
}

// ---------- CORS helper ----------
void set_cors_headers(httplib::Response &res) {
    res.set_header("Access-Control-Allow-Origin", "*");
    res.set_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    res.set_header("Access-Control-Allow-Headers", "Content-Type");
}

int main() {
    httplib::Server svr;

    // Handle CORS preflight requests
    svr.Options(R"(.*)", [](const httplib::Request&, httplib::Response& res) {
        set_cors_headers(res);
        res.status = 204;
    });

    // Home check
    svr.Get("/", [](const httplib::Request&, httplib::Response& res) {
        set_cors_headers(res);
        res.set_content("Online Voting Backend Running ✅", "text/plain");
    });

    // -------------------------
    // POST /login
    // body: { "type": "admin|voter", "userId": "...", "pass": "..." }
    // -------------------------
    svr.Post("/login", [](const httplib::Request& req, httplib::Response& res) {
        set_cors_headers(res);

        json out;
        try {
            auto body = json::parse(req.body);

            string type = body.value("type", "");
            string userId = body.value("userId", "");
            string pass   = body.value("pass", "");

            if (type == "admin") {
                if (userId == "admin" && pass == "admin123") {
                    out["success"] = true;
                    out["message"] = "Admin login success";
                } else {
                    out["success"] = false;
                    out["message"] = "Invalid admin credentials";
                }
            }
            else if (type == "voter") {
                if (voterLogin(userId, pass)) {
                    out["success"] = true;
                    out["message"] = "Voter login success";
                } else {
                    out["success"] = false;
                    out["message"] = "Invalid voter credentials";
                }
            }
            else {
                out["success"] = false;
                out["message"] = "Invalid user type";
            }

            res.set_content(out.dump(), "application/json");
        }
        catch (...) {
            out["success"] = false;
            out["message"] = "Invalid JSON request";
            res.status = 400;
            res.set_content(out.dump(), "application/json");
        }
    });

    // -------------------------
    // GET /candidates
    // -------------------------
    svr.Get("/candidates", [](const httplib::Request&, httplib::Response& res) {
        set_cors_headers(res);

        json out;
        out["candidates"] = json::array();

        auto candidates = loadCandidates();
        for (auto &c : candidates) {
            out["candidates"].push_back({{"id", c.id}, {"name", c.name}});
        }

        res.set_content(out.dump(), "application/json");
    });

    // -------------------------
    // POST /vote
    // body: { "voterId": "...", "candidateId": 1 }
    // -------------------------
    svr.Post("/vote", [](const httplib::Request& req, httplib::Response& res) {
        set_cors_headers(res);

        json out;
        try {
            auto body = json::parse(req.body);

            string voterId = body.value("voterId", "");
            int candidateId = body.value("candidateId", -1);

            if (voterId.empty()) {
                out["success"] = false;
                out["message"] = "Missing voterId";
                res.status = 400;
                res.set_content(out.dump(), "application/json");
                return;
            }

            if (!isValidCandidate(candidateId)) {
                out["success"] = false;
                out["message"] = "Invalid candidate ID";
                res.status = 400;
                res.set_content(out.dump(), "application/json");
                return;
            }

            if (hasVoted(voterId)) {
                out["success"] = false;
                out["message"] = "You already voted! Cannot vote again.";
                res.status = 400;
                res.set_content(out.dump(), "application/json");
                return;
            }

            if (!saveVote(voterId, candidateId)) {
                out["success"] = false;
                out["message"] = "Vote saving failed";
                res.status = 500;
                res.set_content(out.dump(), "application/json");
                return;
            }

            out["success"] = true;
            out["message"] = "Vote submitted successfully!";
            res.set_content(out.dump(), "application/json");
        }
        catch (...) {
            out["success"] = false;
            out["message"] = "Invalid JSON request";
            res.status = 400;
            res.set_content(out.dump(), "application/json");
        }
    });

    // -------------------------
    // GET /results
    // -------------------------
    svr.Get("/results", [](const httplib::Request&, httplib::Response& res) {
        set_cors_headers(res);

        json out;
        out["results"] = json::array();

        auto candidates = loadCandidates();
        auto voteCount = getVoteCount();

        for (auto &c : candidates) {
            out["results"].push_back({
                {"id", c.id},
                {"name", c.name},
                {"votes", voteCount[c.id]}
            });
        }

        res.set_content(out.dump(), "application/json");
    });

    cout << "Backend running at: http://localhost:8080\n";
    svr.listen("0.0.0.0", 8080);

    return 0;
}
