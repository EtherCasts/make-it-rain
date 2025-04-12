// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MakeItRain {
    address public admin;
    uint256 public memberCount = 1;
    uint256 public timesTipped = 0;
    uint256 public totalDistributed = 0;
    uint256 public amountTipped = 0;
    
    // Default number of random tippers to distribute to
    uint256 public defaultRandomRecipients = 5;
    uint256 public maxRandomRecipients = 10;
    
    mapping(address => uint256) public memberBalances;
    mapping(uint256 => address) public memberAddresses;
    
    // ENS Reverse Registrar interface
    interface ENSReverseRegistrar {
        function setName(string memory name) external returns (bytes32);
    }
    
    // ENS Reverse Registrar address on mainnet
    address public constant ENS_REVERSE_REGISTRAR = 0x084b1c3C81545d370f3634392De611CaaBFf8148;
    
    event TipSent(address indexed tipper, address indexed recipient, uint256 directAmount, uint256 communityAmount, uint256 randomRecipients);
    event TipDistributed(address indexed randomRecipient, uint256 amount);
    event MemberAdded(address indexed member, uint256 memberIndex);
    event TipClaimed(address indexed member, uint256 amount);
    
    constructor() {
        admin = msg.sender;
        memberAddresses[0] = admin;
        memberBalances[admin] = 1; // Mark admin as member with 1 wei
        
        // Register with ENS Reverse Registry
        ENSReverseRegistrar(ENS_REVERSE_REGISTRAR).setName("makeitrain.eth");
    }
    
    // Fallback function to receive Ether
    receive() external payable {
        revert("Please use the makeItRain function to send tips");
    }
    
    // Function to update the default number of random recipients
    function setDefaultRandomRecipients(uint256 _defaultRandomRecipients) external {
        require(msg.sender == admin, "Only admin can change default settings");
        require(_defaultRandomRecipients <= maxRandomRecipients, "Cannot exceed max random recipients");
        defaultRandomRecipients = _defaultRandomRecipients;
    }
    
    // Function to update the maximum number of random recipients
    function setMaxRandomRecipients(uint256 _maxRandomRecipients) external {
        require(msg.sender == admin, "Only admin can change max settings");
        maxRandomRecipients = _maxRandomRecipients;
    }
    
    // Function to send a tip with 50% to recipient and 50% to random members
    function makeItRain(address recipient, uint256 randomRecipients) public payable {
        require(msg.value > 0, "Must send Ether to make it rain");
        require(recipient != address(0), "Cannot tip to zero address");
        
        // Ensure randomRecipients is within bounds
        if (randomRecipients == 0) {
            randomRecipients = defaultRandomRecipients;
        }
        if (randomRecipients > maxRandomRecipients) {
            randomRecipients = maxRandomRecipients;
        }
        if (randomRecipients > memberCount) {
            randomRecipients = memberCount;
        }
        
        // Calculate the 50/50 split
        uint256 directAmount = msg.value / 2;
        uint256 communityAmount = msg.value - directAmount; // Use subtraction to avoid rounding issues
        
        // Send 50% directly to the recipient
        if (memberBalances[recipient] == 0) {
            // If recipient is not a member yet, add them
            memberAddresses[memberCount] = recipient;
            memberCount += 1;
            memberBalances[recipient] = 1; // Mark as member with 1 wei
            emit MemberAdded(recipient, memberCount - 1);
        }
        
        // Add the direct amount to recipient's balance
        memberBalances[recipient] += directAmount;
        
        // Calculate the amount per random recipient
        uint256 amountPerRandomRecipient = communityAmount / randomRecipients;
        
        // Distribute the rest to random previous tippers
        for (uint256 i = 0; i < randomRecipients; i++) {
            bytes32 randomData = keccak256(abi.encodePacked(blockhash(block.number - 1), i, msg.sender));
            uint256 randomNumber = uint256(randomData);
            uint256 randomMemberIndex = randomNumber % memberCount;
            address randomTipper = memberAddresses[randomMemberIndex];
            
            // Add to their balance
            memberBalances[randomTipper] += amountPerRandomRecipient;
            emit TipDistributed(randomTipper, amountPerRandomRecipient);
        }
        
        // Update stats
        timesTipped += 1;
        totalDistributed += randomRecipients;
        amountTipped += msg.value;
        
        // Add sender to members if not already a member
        if (memberBalances[msg.sender] == 0) {
            memberAddresses[memberCount] = msg.sender;
            memberCount += 1;
            memberBalances[msg.sender] = 1; // Mark as member with 1 wei
            emit MemberAdded(msg.sender, memberCount - 1);
        }
        
        emit TipSent(msg.sender, recipient, directAmount, communityAmount, randomRecipients);
    }
    
    // Convenience function with default number of random recipients
    function makeItRain(address recipient) external payable {
        makeItRain(recipient, defaultRandomRecipients);
    }
    
    // Function to claim balance
    function claim() external {
        uint256 balance = memberBalances[msg.sender];
        require(balance > 1, "No balance to claim");
        
        // Transfer all but 1 wei to keep membership
        uint256 amountToSend = balance - 1;
        memberBalances[msg.sender] = 1;
        
        // Send the Ether to the caller
        (bool success, ) = msg.sender.call{value: amountToSend}("");
        require(success, "Transfer failed");
        
        emit TipClaimed(msg.sender, amountToSend);
    }
    
    // Admin function to kill the contract
    function kill() external {
        require(msg.sender == admin, "Only admin can kill the contract");
        
        // No need to explicitly deregister from ENS as it's tied to the contract's address
        
        // Destroy the contract and send remaining Ether to admin
        selfdestruct(payable(admin));
    }
}
