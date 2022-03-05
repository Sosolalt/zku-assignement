// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
contract Ballot {
   
    struct Voter {
        uint weight;
        bool voted;  
        address delegate;
        uint vote;  
    }

    struct Proposal {
        bytes32 name;   
        uint voteCount; 
    }

    address public chairperson;

   
    mapping(address => Voter) public voters;


    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames) {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

      
        for (uint i = 0; i < proposalNames.length; i++) {
            
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

   
    function giveRightToVote(address voter) external {
        require(
            msg.sender == chairperson
         &&
            !voters[voter].voted
        &&
        voters[voter].weight == 0);
        voters[voter].weight = 1;
    } // Since we want to compare the performances of this function with our own by running it 10 times,
    // let's just multiply the gas fees for one execution by 10 : 
    // 48 673 x 10 = 486 730 gas

    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");

        require(to != msg.sender, "Self-delegation is disallowed.");

   
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            require(to != msg.sender, "Found loop in delegation.");
        }

       
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
          
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
        
            delegate_.weight += sender.weight;
        }
    }

    function vote(uint proposal) external {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }

 
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

  
    function winnerName() external view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }

    // To optimise gas fees, we are going to put all the addresses in an array,
    // thus allowing us to: 1) only call the smart contract once, therefore reducing a lot of gas fees,
    // 2) only call a function once, even thought it's a more complicated one. We could have 
    // simply created the following function with an array of addresses in argument and execute for each address 
    // the function giveRighToVote but it will still be way more costly since we are calling a function (giveRightToVote)
    // 3) finally, we are going to try do optimize our function:

    function giveAllAddressesRightToVote(address[] memory _voters) external {
        require(
            msg.sender == chairperson,
            "Only chairperson can give right to vote."
        ); 
        // verifying that the caller is the chairperson is only required once 
        // Compare to the previous function, for 10 addresses we execute this line of code 9 times less so we will use less gas fees

                for (uint256 i = 0; i < _voters.length; ++i) {
            address voter = _voters[i];
            require(
                !voters[voter].voted,
                "A voter already voted."
            ); //if one voter is not valid, then the function stops and nobody receives voting rights
            require(voters[voter].weight == 0);
            voters[voter].weight = 1;
        }
        // with this function, the gas cost for the execution for 10 addresses is 279 274
        // whereas the gas cost for running the original function for 10 addresses is 486 730
        // We therefore have an improvement of 207 456 gas fees
    }
}
