pragma solidity >=0.4.22 <0.7.0;

contract CampaignFactory {
    address public deployedCampaigns;
    
    constructor (uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }
    
    function getDeployedCampaign() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint voteCount;
        mapping(address => bool) votes;
    }
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;
    
    constructor (uint minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }
    
    function contribute() public payable {
        require(msg.value > minimumContribution);
        
        approvers[msg.sender] = true;
        approversCount++;
    }
    
    function createRequest(string memory description, uint value, address recipient) public restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            voteCount: 0
        });
        
        requests.push(newRequest);
    }
    
    function approveRequest(uint index) public {
        Request storage request = requests[index];
        
        require(approvers[msg.sender]);
        require(!request.votes[msg.sender]);
        
        request.votes[msg.sender] = true;
        request.voteCount++;
    }
    
    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        
        require(request.voteCount > (approversCount / 2));
        require(!request.complete);
        
        request.recipient.transfer(request.value);
        request.complete = true;
    }
}