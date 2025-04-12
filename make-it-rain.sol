// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MakeItRain {
    address public admin;
    uint256 public memberCount = 1;
    uint256 public timesTipped = 0;
    uint256 public splitsTipped = 0;
    uint256 public amountTipped = 0;
    
    mapping(address => uint256) public memberBalances;
    mapping(uint256 => address) public memberAddresses;
    
    // NameReg interface (simplified)
    interface NameReg {
        function register(string memory name) external;
        function unregister() external;
    }
    
    NameReg nameReg = NameReg(0x11d11764cd7f6ecda172e0b72370e6ea7f75f290);
    
    constructor() {
        admin = msg.sender;
        memberAddresses[0] = admin;
        memberBalances[admin] = 1; // Mark admin as member with 1 wei
        
        // Register with NameReg
        nameReg.register("Make It Rain");
    }
    
    // Fallback function to receive Ether
    receive() external payable {
        // Default to 1 split if no data is provided
        makeItRain(1);
    }
    
    // Function to receive Ether with a specified number of splits
    function makeItRain(uint256 splits) public payable {
        require(msg.value > 0, "Must send Ether to make it rain");
        
        // Ensure splits is between 1 and min(memberCount, 32)
        if (splits < 1) splits = 1;
        if (splits > 32) splits = 32;
        if (splits > memberCount) splits = memberCount;
        
        uint256 splitTipAmount = msg.value / splits;
        
        // Update stats
        timesTipped += 1;
        splitsTipped += splits;
        amountTipped += msg.value;
        
        // Loop through splits and draw random member for each
        for (uint256 i = 0; i < splits; i++) {
            bytes32 randomData = keccak256(abi.encodePacked(blockhash(block.number - 1), i));
            uint256 randomNumber = uint256(randomData);
            uint256 randomMemberIndex = randomNumber % memberCount;
            address randomTipper = memberAddresses[randomMemberIndex];
            
            memberBalances[randomTipper] += splitTipAmount;
        }
        
        // Add address of caller to members if not already a member
        if (memberBalances[msg.sender] == 0) {
            memberAddresses[memberCount] = msg.sender;
            memberCount += 1;
            memberBalances[msg.sender] = 1; // Mark as member with 1 wei
        }
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
    }
    
    // Admin function to kill the contract
    function kill() external {
        require(msg.sender == admin, "Only admin can kill the contract");
        
        // Deregister from NameReg
        nameReg.unregister();
        
        // Destroy the contract and send remaining Ether to admin
        selfdestruct(payable(admin));
    }
}
