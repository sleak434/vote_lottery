pragma solidity ^0.4.18;

import "./Ownable.sol";
import "./SafeMath.sol";

contract votelottery is Ownable {
    using SafeMath for uint256;
    mapping(address => bool) public voters;
    struct cadidate {
        string name;
        uint256 votes;
    }
    cadidate[] public candidates;
    
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
        for (uint256 i = 0; i < length; i.add(1)) {
            require(keccak256(bytes(candidate_name)) != keccak256(bytes(candidates[i].name)));
        }
        candidates.length = candidates.length.add(1);
        candidates[length].name = candidate_name;
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
        // call some functions
    }
    
    // 이미 투표를 했으면 투표할 수 없다.
    modifier canVote() {
        require(voters[msg.sender] == false);
        _;
    }
    
    // 보유하고 있는 투표권을 후보자(candidates[candidate])에 행사한다.
    function vote(uint256 candidate) canVote vote_not_over public {
        require(voters[msg.sender] != true);
        
        voters[msg.sender] = true;
        // 유효하지 않은 후보자일 경우 트랜잭션 전 상태로 돌아가게 예외처리 되있음
        candidates[candidate].votes.add(1);
    }
}
