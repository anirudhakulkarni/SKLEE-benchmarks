{"BasicToken.sol":{"content":"pragma solidity ^0.4.24;\n\n\nimport \"./ERC20Basic.sol\";\nimport \"./SafeMath.sol\";\n\n\n/**\n * @title Basic token\n * @dev Basic version of StandardToken, with no allowances.\n */\ncontract BasicToken is ERC20Basic {\n  using SafeMath for uint256;\n\n  mapping(address =\u003e uint256) internal balances;\n\n  uint256 internal totalSupply_;\n\n  /**\n  * @dev Total number of tokens in existence\n  */\n  function totalSupply() public view returns (uint256) {\n    return totalSupply_;\n  }\n\n  /**\n  * @dev Transfer token for a specified address\n  * @param _to The address to transfer to.\n  * @param _value The amount to be transferred.\n  */\n  function transfer(address _to, uint256 _value) public returns (bool) {\n    require(_value \u003c= balances[msg.sender]);\n    require(_to != address(0));\n\n    balances[msg.sender] = balances[msg.sender].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    emit Transfer(msg.sender, _to, _value);\n    return true;\n  }\n\n  /**\n  * @dev Gets the balance of the specified address.\n  * @param _owner The address to query the the balance of.\n  * @return An uint256 representing the amount owned by the passed address.\n  */\n  function balanceOf(address _owner) public view returns (uint256) {\n    return balances[_owner];\n  }\n\n}\n"},"CappedToken.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./MintableToken.sol\";\n\n\n/**\n * @title Capped token\n * @dev Mintable token with a token cap.\n */\ncontract CappedToken is MintableToken {\n\n  uint256 public cap;\n\n  constructor(uint256 _cap) public {\n    require(_cap \u003e 0);\n    cap = _cap;\n  }\n\n  /**\n   * @dev Function to mint tokens\n   * @param _to The address that will receive the minted tokens.\n   * @param _amount The amount of tokens to mint.\n   * @return A boolean that indicates if the operation was successful.\n   */\n  function mint(\n    address _to,\n    uint256 _amount\n  )\n    public\n    returns (bool)\n  {\n    require(totalSupply_.add(_amount) \u003c= cap);\n\n    return super.mint(_to, _amount);\n  }\n\n}\n"},"CapToken.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./MintableToken.sol\";\nimport \"./CappedToken.sol\";\n\ncontract VEL is CappedToken {\n \n    string public name = \"VEL\";\n    string public symbol = \"VEL\";\n    uint8 public decimals = 18;\n\n    constructor(\n        uint256 _cap\n        )\n        public\n        CappedToken( _cap ) {\n    }\n}\n\n\n\n\n"},"ERC20.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./ERC20Basic.sol\";\n\n\n/**\n * @title ERC20 interface\n * @dev see https://github.com/ethereum/EIPs/issues/20\n */\ncontract ERC20 is ERC20Basic {\n  function allowance(address _owner, address _spender)\n    public view returns (uint256);\n\n  function transferFrom(address _from, address _to, uint256 _value)\n    public returns (bool);\n\n  function approve(address _spender, uint256 _value) public returns (bool);\n  event Approval(\n    address indexed owner,\n    address indexed spender,\n    uint256 value\n  );\n}\n"},"ERC20Basic.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/**\n * @title ERC20Basic\n * @dev Simpler version of ERC20 interface\n * See https://github.com/ethereum/EIPs/issues/179\n */\ncontract ERC20Basic {\n  function totalSupply() public view returns (uint256);\n  function balanceOf(address _who) public view returns (uint256);\n  function transfer(address _to, uint256 _value) public returns (bool);\n  event Transfer(address indexed from, address indexed to, uint256 value);\n}\n"},"MintableToken.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./StandardToken.sol\";\nimport \"./Ownable.sol\";\n\n\n/**\n * @title Mintable token\n * @dev Simple ERC20 Token example, with mintable token creation\n * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol\n */\ncontract MintableToken is StandardToken, Ownable {\n  event Mint(address indexed to, uint256 amount);\n  event MintFinished();\n\n  bool public mintingFinished = false;\n\n\n  modifier canMint() {\n    require(!mintingFinished);\n    _;\n  }\n\n  modifier hasMintPermission() {\n    require(msg.sender == owner);\n    _;\n  }\n\n  /**\n   * @dev Function to mint tokens\n   * @param _to The address that will receive the minted tokens.\n   * @param _amount The amount of tokens to mint.\n   * @return A boolean that indicates if the operation was successful.\n   */\n  function mint(\n    address _to,\n    uint256 _amount\n  )\n    public\n    hasMintPermission\n    canMint\n    returns (bool)\n  {\n    totalSupply_ = totalSupply_.add(_amount);\n    balances[_to] = balances[_to].add(_amount);\n    emit Mint(_to, _amount);\n    emit Transfer(address(0), _to, _amount);\n    return true;\n  }\n\n  /**\n   * @dev Function to stop minting new tokens.\n   * @return True if the operation was successful.\n   */\n  function finishMinting() public onlyOwner canMint returns (bool) {\n    mintingFinished = true;\n    emit MintFinished();\n    return true;\n  }\n}\n"},"Ownable.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/**\n * @title Ownable\n * @dev The Ownable contract has an owner address, and provides basic authorization control\n * functions, this simplifies the implementation of \"user permissions\".\n */\ncontract Ownable {\n  address public owner;\n\n\n  event OwnershipRenounced(address indexed previousOwner);\n  event OwnershipTransferred(\n    address indexed previousOwner,\n    address indexed newOwner\n  );\n\n\n  /**\n   * @dev The Ownable constructor sets the original `owner` of the contract to the sender\n   * account.\n   */\n  constructor() public {\n    owner = msg.sender;\n  }\n\n  /**\n   * @dev Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    require(msg.sender == owner);\n    _;\n  }\n\n  /**\n   * @dev Allows the current owner to relinquish control of the contract.\n   * @notice Renouncing to ownership will leave the contract without an owner.\n   * It will not be possible to call the functions with the `onlyOwner`\n   * modifier anymore.\n   */\n  function renounceOwnership() public onlyOwner {\n    emit OwnershipRenounced(owner);\n    owner = address(0);\n  }\n\n  /**\n   * @dev Allows the current owner to transfer control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function transferOwnership(address _newOwner) public onlyOwner {\n    _transferOwnership(_newOwner);\n  }\n\n  /**\n   * @dev Transfers control of the contract to a newOwner.\n   * @param _newOwner The address to transfer ownership to.\n   */\n  function _transferOwnership(address _newOwner) internal {\n    require(_newOwner != address(0));\n    emit OwnershipTransferred(owner, _newOwner);\n    owner = _newOwner;\n  }\n}\n"},"SafeMath.sol":{"content":"pragma solidity ^0.4.24;\n\n\n/**\n * @title SafeMath\n * @dev Math operations with safety checks that throw on error\n */\nlibrary SafeMath {\n\n  /**\n  * @dev Multiplies two numbers, throws on overflow.\n  */\n  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\n    // Gas optimization: this is cheaper than asserting \u0027a\u0027 not being zero, but the\n    // benefit is lost if \u0027b\u0027 is also tested.\n    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522\n    if (_a == 0) {\n      return 0;\n    }\n\n    c = _a * _b;\n    assert(c / _a == _b);\n    return c;\n  }\n\n  /**\n  * @dev Integer division of two numbers, truncating the quotient.\n  */\n  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {\n    // assert(_b \u003e 0); // Solidity automatically throws when dividing by 0\n    // uint256 c = _a / _b;\n    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn\u0027t hold\n    return _a / _b;\n  }\n\n  /**\n  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).\n  */\n  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {\n    assert(_b \u003c= _a);\n    return _a - _b;\n  }\n\n  /**\n  * @dev Adds two numbers, throws on overflow.\n  */\n  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {\n    c = _a + _b;\n    assert(c \u003e= _a);\n    return c;\n  }\n}\n"},"StandardToken.sol":{"content":"pragma solidity ^0.4.24;\n\nimport \"./BasicToken.sol\";\nimport \"./ERC20.sol\";\n\n\n/**\n * @title Standard ERC20 token\n *\n * @dev Implementation of the basic standard token.\n * https://github.com/ethereum/EIPs/issues/20\n * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol\n */\ncontract StandardToken is ERC20, BasicToken {\n\n  mapping (address =\u003e mapping (address =\u003e uint256)) internal allowed;\n\n\n  /**\n   * @dev Transfer tokens from one address to another\n   * @param _from address The address which you want to send tokens from\n   * @param _to address The address which you want to transfer to\n   * @param _value uint256 the amount of tokens to be transferred\n   */\n  function transferFrom(\n    address _from,\n    address _to,\n    uint256 _value\n  )\n    public\n    returns (bool)\n  {\n    require(_value \u003c= balances[_from]);\n    require(_value \u003c= allowed[_from][msg.sender]);\n    require(_to != address(0));\n\n    balances[_from] = balances[_from].sub(_value);\n    balances[_to] = balances[_to].add(_value);\n    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);\n    emit Transfer(_from, _to, _value);\n    return true;\n  }\n\n  /**\n   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.\n   * Beware that changing an allowance with this method brings the risk that someone may use both the old\n   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\n   * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n   * @param _spender The address which will spend the funds.\n   * @param _value The amount of tokens to be spent.\n   */\n  function approve(address _spender, uint256 _value) public returns (bool) {\n    allowed[msg.sender][_spender] = _value;\n    emit Approval(msg.sender, _spender, _value);\n    return true;\n  }\n\n  /**\n   * @dev Function to check the amount of tokens that an owner allowed to a spender.\n   * @param _owner address The address which owns the funds.\n   * @param _spender address The address which will spend the funds.\n   * @return A uint256 specifying the amount of tokens still available for the spender.\n   */\n  function allowance(\n    address _owner,\n    address _spender\n   )\n    public\n    view\n    returns (uint256)\n  {\n    return allowed[_owner][_spender];\n  }\n\n  /**\n   * @dev Increase the amount of tokens that an owner allowed to a spender.\n   * approve should be called when allowed[_spender] == 0. To increment\n   * allowed value is better to use this function to avoid 2 calls (and wait until\n   * the first transaction is mined)\n   * From MonolithDAO Token.sol\n   * @param _spender The address which will spend the funds.\n   * @param _addedValue The amount of tokens to increase the allowance by.\n   */\n  function increaseApproval(\n    address _spender,\n    uint256 _addedValue\n  )\n    public\n    returns (bool)\n  {\n    allowed[msg.sender][_spender] = (\n      allowed[msg.sender][_spender].add(_addedValue));\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n    return true;\n  }\n\n  /**\n   * @dev Decrease the amount of tokens that an owner allowed to a spender.\n   * approve should be called when allowed[_spender] == 0. To decrement\n   * allowed value is better to use this function to avoid 2 calls (and wait until\n   * the first transaction is mined)\n   * From MonolithDAO Token.sol\n   * @param _spender The address which will spend the funds.\n   * @param _subtractedValue The amount of tokens to decrease the allowance by.\n   */\n  function decreaseApproval(\n    address _spender,\n    uint256 _subtractedValue\n  )\n    public\n    returns (bool)\n  {\n    uint256 oldValue = allowed[msg.sender][_spender];\n    if (_subtractedValue \u003e= oldValue) {\n      allowed[msg.sender][_spender] = 0;\n    } else {\n      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);\n    }\n    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);\n    return true;\n  }\n\n}\n"}}