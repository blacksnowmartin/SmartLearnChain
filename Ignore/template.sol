// This is a simplified and fictional smart contract example.

pragma solidity ^0.8.0;

contract ICPPlatform {
    address public admin;
    mapping(address => uint256) public userBalances;
    mapping(address => bool) public registeredUsers;

    event TokensPurchased(address indexed buyer, uint256 amount);
    event FeePaid(address indexed payer, address indexed recipient, uint256 amount);
    event UserRegistered(address indexed user);
    event FundsWithdrawn(address indexed recipient, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can call this function");
        _;
    }

    modifier onlyRegisteredUser() {
        require(registeredUsers[msg.sender], "User is not registered");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerUser() external {
        require(!registeredUsers[msg.sender], "User is already registered");
        registeredUsers[msg.sender] = true;
        emit UserRegistered(msg.sender);
    }

    function purchaseICPTokens(uint256 amount) external onlyRegisteredUser {
        // In a real implementation, this would involve a token transfer
        userBalances[msg.sender] += amount;
        emit TokensPurchased(msg.sender, amount);
    }

    function payFees(address recipient, uint256 amount) external onlyRegisteredUser {
        require(userBalances[msg.sender] >= amount, "Insufficient funds");
        userBalances[msg.sender] -= amount;
        userBalances[recipient] += amount;
        emit FeePaid(msg.sender, recipient, amount);
    }

    function getBalance() external view returns (uint256) {
        return userBalances[msg.sender];
    }

    function withdrawFunds(uint256 amount) external onlyAdmin {
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(admin).transfer(amount);
        emit FundsWithdrawn(admin, amount);
    }

    function updateAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
    }

    // Function to receive Ether
    receive() external payable {}

    // Fallback function
    fallback() external payable {}
}
