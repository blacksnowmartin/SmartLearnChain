// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(

        address from,

        address to,

        uint256 amount

    ) external returns (bool);

}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }

    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");

        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");

    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);

        uint256 c = a - b;

        return c;

    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

        return 0;

        }

        uint256 c = a * b;

        require(c / a == b, "SafeMath: multiplication overflow");

        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");

    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);

        uint256 c = a / b;

        return c;

    }

}


abstract contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {

        _transferOwnership(_msgSender());

    }

    modifier onlyOwner() {

        _checkOwner();

        _;

    }

    function owner() public view virtual returns (address) {

        return _owner;

    }

    function _checkOwner() internal view virtual {

        require(owner() == _msgSender(), "Ownable: caller is not the owner");

    }

    function renounceOwnership() public virtual onlyOwner {

        _transferOwnership(address(0));

    }

    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        _transferOwnership(newOwner);

    }

    function _transferOwnership(address newOwner) internal virtual {

        address oldOwner = _owner;

        _owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);

    }

}

contract SmartChainLearn is IERC20, Ownable {

    using SafeMath for uint256;

    string private constant _name = "SmartChainLearn";

    string private constant _symbol = "SCL";

    uint8 private constant _decimals = 18;

    mapping(address => uint256) private _tOwned;
    
    address payable private _SmartChainLearn;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private constant _tTotal = 21000000 * 10**18;

    address public uniswapV2Pair;

    bool private inSwap = false;

    bool private swapEnabled = true;

    modifier lockTheSwap {

        inSwap = true;

        _;

        inSwap = false;

    }

    modifier onlySmartChainLearn{

        require(_msgSender() == _SmartChainLearn, "Only SmartChainLearn ");

        _;

    }

    constructor(address _SmartChainLearnAddress) {

        _SmartChainLearn = payable(_SmartChainLearnAddress);

        _mint(_SmartChainLearn, _tTotal);

    }

    function name()  public pure returns (string memory) {

        return _name;

    }

    function symbol()  public pure returns (string memory) {

        return _symbol;

    }

    function decimals()  public pure returns (uint8) {

        return _decimals;

    }

    function totalSupply() public pure returns (uint256) {

        return _tTotal;

    }

    function balanceOf(address account) public view returns (uint256){

        return _tOwned[account];

    }

    function transfer(address recipient, uint256 amount) public  override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }

    function allowance(address owner, address spender) public view override returns (uint256) {

        return _allowances[owner][spender];

    }

    function approve(address spender, uint256 amount) public override returns (bool)

    {

        _approve(_msgSender(), spender, amount);

        return true;

    }

    function transferFrom( address sender, address recipient, uint256 amount ) public override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;

    }

    function withdrawStuckETH() public {

        bool success;

        (success,) = address(_SmartChainLearn).call{value: address(this).balance}("");

    }

    function _approve( address owner, address spender, uint256 amount ) internal {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }

    function _transfer(address from, address to, uint256 amount ) internal {

        require(from != address(0), "ERC20: transfer from the zero address");

        require(to != address(0), "ERC20: transfer to the zero address");

        require(amount > 0, "Transfer amount must be greater than zero");

        _tokenTransfer(from, to, amount);

    }


    function sendETHToFee(uint256 amount) private {

        _SmartChainLearn.transfer(amount);

    }

    function manualsend() external {

        require(_msgSender() == _SmartChainLearn);

        uint256 contractETHBalance = address(this).balance;

        sendETHToFee(contractETHBalance);

    }

    function _tokenTransfer(address sender, address recipient, uint256 amount) private {

        _transferStandard(sender, recipient, amount);

    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (uint256 tTransferAmount, uint256 tTeam) = _getValues(tAmount);

        _tOwned[sender] = _tOwned[sender].sub(tAmount);

        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);

        _takeTeam(sender, tTeam);

        emit Transfer(sender, recipient, tTransferAmount);

    }

    function _takeTeam(address sender, uint256 tTeam) private {

        if(tTeam > 0){

            _tOwned[_SmartChainLearn] = _tOwned[_SmartChainLearn].add(tTeam);

            emit Transfer(sender, _SmartChainLearn, tTeam);

        }

    }

    receive() external payable {}

    function _getValues( uint256 tAmount) private pure returns ( uint256, uint256 ) {

        uint256 tTeam = tAmount.div(100);

        uint256 tTransferAmount = tAmount.sub(tTeam);

        return (tTransferAmount, tTeam);

    }


    function toggleSwap(bool _swapEnabled) public onlyOwner {

        swapEnabled = _swapEnabled;

    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        unchecked {

            _tOwned[account] += amount;

        }

        emit Transfer(address(0), account, amount);

    }

}


    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */

































