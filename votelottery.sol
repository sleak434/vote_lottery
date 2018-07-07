pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./pairing.sol";

contract votelottery is Ownable {
    using Pairing for *;
    using SafeMath for uint256;
    mapping(address => bool) public voters;
    address [] public tickets;
    struct candidate {
        string name;
        uint256 votes;
    }
    candidate[] public candidates;
    
    struct key {
        Pairing.G1Point g1;
        Pairing.G2Point g2;
    }
    key [] public keys;
    
    bool public vote_started;
    bool public vote_is_over;
    
    modifier vote_not_over() {
        require(vote_is_over == false);
        _;
    }
    
    constructor () public {
        vote_started = false;
        vote_is_over = false;
    }
    
    event VoteResult(
        string indexed name,	
        uint indexed votes	
    );
    
    event winnerResult(address _address, uint _amount);
    
    function addKey(uint256 p1x, uint256 p1y,
    uint256 p2x1, uint256 p2x2, uint256 p2y1, uint256 p2y2) onlyOwner public {
        Pairing.G1Point memory g1 = Pairing.G1Point(p1x, p1y);
        Pairing.G2Point memory g2 = Pairing.G2Point([p2x1,p2x2],[p2y1,p2y2]);
        keys.push(key(g1, g2));
    }
    
    function renounceOwnership() public onlyOwner {
        require(vote_is_over == true);
        super.renounceOwnership();
    }
    
    function () external onlyOwner vote_not_over payable {
        require(vote_started == false);
    }
    
    function balance() public constant returns(uint256)  {
        return address(this).balance;
    } 
    
   function addCandidate(string candidate_name) onlyOwner vote_not_over public {
        require(bytes(candidate_name).length > 0);
        require(vote_started == false);
        uint256 length = candidates.length;
        for (uint256 i = 0; i < length; i = i.add(1)) {
            require(keccak256(bytes(candidate_name)) != keccak256(bytes(candidates[i].name)));
        }
        candidates.push(candidate(candidate_name, 0));
    }
    
   function addVoters(address[] new_voters) onlyOwner vote_not_over public {
        require(vote_started == false);
        uint256 length = new_voters.length;
        for (uint256 i = 0; i < length; i = i.add(1)) {
            require(new_voters[i] != address(0));
            voters[new_voters[i]] = true;
        }
    }
    
   function startVote() onlyOwner vote_not_over public {
        require(candidates.length > 0);
        require(vote_started == false);
        vote_started = true;
    }
    
   function endVote() onlyOwner vote_not_over public {
        require(vote_started == true);
        vote_is_over = true;
        
        getResult();
        
        uint256 winnerIdx = random(tickets.length); 	
        address winner = tickets[winnerIdx]; 	
        transferTotalEtherToWinner(winner); 
    }
    
    modifier canVote() {
        require(voters[msg.sender] == true);
        require(vote_started == true);
        _;
    }
    
    // 보유하고 있는 투표권을 후보자(candidates[candidate])에 행사한다.
    function vote(uint256 candidate_, uint256 p1x, uint256 p1y,
    uint256 p2x1, uint256 p2x2, uint256 p2y1, uint256 p2y2) canVote vote_not_over public {
        voters[msg.sender] = false;
        // 유효하지 않은 후보자일 경우 트랜잭션 전 상태로 돌아가게 예외처리 되있음
        candidates[candidate_].votes = candidates[candidate_].votes.add(1);
        tickets.push(msg.sender);
    }
    
    function random(uint256 _range) private view returns (uint256) {
        return uint256(keccak256(block.timestamp, block.difficulty))%_range;
    }
    
    function transferTotalEtherToWinner(address _winner) public onlyOwner payable {
        
        require(balance() > 0);
        uint256 amount = balance();
        _winner.transfer(amount);
        emit winnerResult(_winner, amount);
    }
    
    function getResult() private {	
        for(uint256 p = 0; p < candidates.length ; p++) {	
            emit VoteResult(candidates[p].name, candidates[p].votes);    	
        }
    }
}
