pragma solidity ^0.4.0;

/*
  Election Contract, fair election for a speciofied amount of time and allowed a specified of people to vote in it
*/

contract Election{

  struct Candidate{
    string name;
    uint voteCount;   // number of votes
  }

  struct Voter{
    bool voted;     // already voted
    uint voteIndex;   // who it has voted for
    uint weight;
  }

  address public owner;
  string public name;
  mapping(address => Voter) public voters;
  Candidate[] public candidates;
  uint public auctionEnd;     // time the election ends

  event ElectionResult(string name, uint voteCount);

  // passing a string array functions in solidity can not accept or return 2 dimensional arrays, the string datatype is implemented as a array of bytes 32

  function Election(string _name, uint durationMinutes, string candidate1, string candidate2){
    owner = msg.sender;
    name = _name;
    auctionEnd = now + (durationMinutes * 1 minutes);

    candidates.push(Candidate(candidate1, 0));
    candidates.push(Candidate(candidate2, 0));
  }

  // allows the owner of the contract to giving voting rights to any address
  function authorize(address voter){
    require(msg.sender == owner);
    require(!voters[voter].voted);

    voters[voter].weight = 1;
  }

  function vote(uint voteIndex){
    require(now < auctionEnd);    // check if the time to vote has not already passed
    require(!voters[msg.sender].voted); // check if the sender of the vote has not voted before

    voters[msg.sender].voted = true;
    voters[msg.sender].voteIndex = voteIndex;

    candidates[voteIndex].voteCount += voters[msg.sender].weight;
  }

  function end(){
    require(msg.sender == owner);
    require(now >= auctionEnd);

    for(uint i=0; i < candidates.length; i++){
      ElectionResult(candidates[i].name, candidates[i].voteCount);
    }
  }
}
