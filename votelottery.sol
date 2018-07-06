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
        for (uint256 i = 0; i < length; i = i.add(1)) {
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
    
    
    event winner(string _msg, address _address, uint _amount);
    
    
    function random(uint256 _range) private view returns (uint256) {
        uint256 randNounce = 0;
        return uint256(keccak256(now, msg.sender, randNounce)) % _range;
    }
    

    function transferToWinner(address _winner, uint256 _amount) public onlyOwner payable {
        
        require(balance() >= _amount);
        
        _winner.transfer(_amount);
        
        emit winner('winner is', _winner, _amount);

    }
}
