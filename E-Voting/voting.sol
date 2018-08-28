pragma solidity ^0.4.24;

contract Voting {

    struct voter {
        uint addr_count;
        mapping (uint => address) addr_voter;
    }
    
    mapping (address => voter) reg_user; 
    mapping (address => vote) reg_vote; 
    
    struct candidate {
        uint candi_count;
        mapping (uint => one_candi) candi; 
    }
    
    struct one_candi {
        uint vote_count;
        string name;
    }
    
    struct vote {
        uint startTime; // 투표 시작시간
        uint endTime; // 투표 종료시간
        uint totalVoting; // 총 투표수 
        //bool exists; // 존재 여부 
        bytes32 voteName; // 투표 이름
    }

    mapping(address => candidate) candidateList;
    
    mapping(address => bool) user_check;
    
    function atNow() private view returns(uint)
    {
        return now;
    }
    
    function voting(address addr_vote, address addr_voter, uint candi_index) public {
        require(user_check[addr_voter] == false);
        require(reg_vote[addr_vote].endTime > atNow());
        
        candidate storage c = candidateList[addr_vote];
        c.candi[candi_index].vote_count++;
        
        vote storage v = reg_vote[addr_vote];
        
        v.totalVoting++;
        user_check[addr_voter] = true;
    }
    
    function voter_set (address addr_vote, address addr_voter) public { 
        voter storage v = reg_user[addr_vote];
        
        v.addr_count++;
        v.addr_voter[v.addr_count] = addr_voter;
    }
    
    function voter_get(address addr_vote, uint voter_index) view public returns (address) {
        voter storage v = reg_user[addr_vote];

        return v.addr_voter[voter_index];
    }
    
    function createVote (address addr_vote, uint _startTime, uint _endTime, bytes32 _voteName) public {
        reg_vote[addr_vote].startTime = _startTime;
        reg_vote[addr_vote].endTime = _endTime;
        reg_vote[addr_vote].voteName = _voteName;

    }
    
    function removeVote(address addr_vote) public {
        delete reg_vote[addr_vote];
    }

    function insertCandidate(address addr_vote, string _name) public {
        candidate storage c = candidateList[addr_vote];
        
        c.candi_count++;
        c.candi[c.candi_count].name = _name;
    }

    function removeCandidate(address addr_vote, uint candi_index ) public {
        delete candidateList[addr_vote].candi[candi_index];
    }

    function numberOfTotalVoting(address addr_vote) public view  returns (uint) {
        vote storage v = reg_vote[addr_vote];
        return v.totalVoting;

    }
    
    function numberOfVoting(address addr_vote, uint candi_index ) public view  returns (uint) {
        require(candidateList[addr_vote].candi_count >= candi_index);
        return candidateList[addr_vote].candi[candi_index].vote_count;
    }
}