import "./Ownable.sol";
import "./Safemath.sol";
pragma solidity 0.5.12;

contract ERC20 is Ownable {
    
    using SafeMath for uint256; 

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint256 private _decimals;
    mapping (address => uint256) private _balances;
    
    mapping (address => mapping (address => uint256)) private _allowances;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value, uint _newApprovedTotal);
    
    event TransferFromSuccessfulEvent (address sender, uint256 amountTransferred, address recipient, address addressThatIsTransferring);

    constructor (string memory name, string memory symbol, uint256 totalSupply) public {
        _name = name;
        _symbol = symbol;
        _totalSupply = totalSupply;
        _decimals = 18;
    }

    function name() public view returns (string memory erc20Name) {
        return _name; 
    }

    function symbol() public view returns (string memory erc20Symbol) {
        return _symbol; 
    }

    function decimals() public view returns (uint256 erc20Decimals) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256 erc20TotalSupply) {
        return _totalSupply;
    }

    function balanceOf(address accountToShowBalanceOf) public view returns (uint256 balanceOfAddress) {
        return _balances[accountToShowBalanceOf];
    }

    function mint(address accountToBeMintedTo, uint256 amount) public onlyOwner{
        require (amount > 0);
        require (accountToBeMintedTo != address(0));

        _balances[accountToBeMintedTo] = _balances[accountToBeMintedTo].add(amount);
        _totalSupply = _totalSupply.add(amount);
    }

    function transfer(address recipientAddress, uint256 amount) public returns (bool success) {
        require (amount <= _balances[msg.sender]);
        require (amount >= 0);
        require (recipientAddress != address(0));
       
        uint256 balanceBeforeSending;
        uint256 balanceBeforeReceiving;
        
        balanceBeforeSending = _balances[msg.sender];
        balanceBeforeReceiving = _balances[recipientAddress]; 
        
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipientAddress] = _balances[recipientAddress].add(amount);
        
        assert (_balances[msg.sender] == (balanceBeforeSending.sub(amount)));
        assert (_balances[recipientAddress] == (balanceBeforeReceiving.add(amount)));
             
        success = true;        
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require (_value <= _balances[msg.sender]); 
        
        uint256 _newApprovedTotal;
        
        // correct? new approvals stack on top of each other in this fashion.
        _allowances[msg.sender][_spender] = _allowances[msg.sender][_spender].add(_value);
        _newApprovedTotal = _allowances[msg.sender][_spender];
        
        emit Approval (msg.sender, _spender, _value, _newApprovedTotal);
        success = true;        
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return _allowances[_owner][_spender];
    }
    
    function transferFrom (address senderAddress, address recipientAddress, uint256 amount) public returns (bool success) {
        require (amount <= _allowances[senderAddress][msg.sender]);        
        require (amount <= _balances[senderAddress]);
        require (amount >= 0);
        require (recipientAddress != address(0));
        require (senderAddress != address(0));
       
        uint256 balanceBeforeSending;
        uint256 balanceBeforeReceiving;
        uint256 allowanceBeforeTransfer;
        
        balanceBeforeSending = _balances[senderAddress];
        balanceBeforeReceiving = _balances[recipientAddress]; 
        allowanceBeforeTransfer = _allowances[senderAddress][msg.sender];
        
        _balances[senderAddress] = _balances[senderAddress].sub(amount);
        _balances[recipientAddress] = _balances[recipientAddress].add(amount);
        
        _allowances[senderAddress][msg.sender] = _allowances[senderAddress][msg.sender].sub(amount);
        
        assert (_balances[senderAddress] == balanceBeforeSending.sub(amount));
        assert (_balances[recipientAddress] == balanceBeforeReceiving.add(amount));
        assert (_allowances[senderAddress][msg.sender] == allowanceBeforeTransfer.sub(amount));
        success = true;        
    }
}
