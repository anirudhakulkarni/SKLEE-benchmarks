{{
  "language": "Solidity",
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 500
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "recoverable-wallet.sol": {
      "content": "pragma solidity 0.6.2;\npragma experimental ABIEncoderV2;\n\n/// @notice https://eips.ethereum.org/EIPS/eip-1820\ninterface Erc1820Registry {\n\tfunction setInterfaceImplementer(address _target, bytes32 _interfaceHash, address _implementer) external;\n}\n\n/// @notice https://eips.ethereum.org/EIPS/eip-777\ncontract Erc777TokensRecipient {\n\tconstructor() public {\n\t\t// keccak256(abi.encodePacked(\"ERC777TokensRecipient\")) == 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b\n\t\tErc1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24).setInterfaceImplementer(address(this), 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b, address(this));\n\t}\n\n\t/// @notice called when someone attempts to transfer ERC-777 tokens to this address.  If this function were to throw or doesn't exist, then the token transfer would fail.\n\tfunction tokensReceived(address, address, address, uint256, bytes calldata, bytes calldata) external { }\n\n\t/// @notice Indicates whether the contract implements the interface `interfaceHash` for the address `_implementer` or not.\n\t/// @param _interfaceHash keccak256 hash of the name of the interface\n\t/// @param _implementer Address for which the contract will implement the interface\n\t/// @return ERC1820_ACCEPT_MAGIC only if the contract implements `interfaceHash` for the address `_implementer`.\n\tfunction canImplementInterfaceForAddress(bytes32 _interfaceHash, address _implementer) external view returns(bytes32) {\n\t\t// keccak256(abi.encodePacked(\"ERC777TokensRecipient\")) == 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b\n\t\tif (_implementer == address(this) && _interfaceHash == 0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b) {\n\t\t\t// keccak256(abi.encodePacked(\"ERC1820_ACCEPT_MAGIC\")) == 0xa2ef4600d742022d532d4747cb3547474667d6f13804902513b2ec01c848f4b4\n\t\t\treturn 0xa2ef4600d742022d532d4747cb3547474667d6f13804902513b2ec01c848f4b4;\n\t\t} else {\n\t\t\treturn bytes32(0);\n\t\t}\n\t}\n}\n\n/**\n * @dev Library for managing map of recoverer.\n *\n * Original cribbed from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/1e0f07751ea0badce1f51bc23578b5b1ddb4b464/contracts/utils/EnumerableSet.sol, but heavily modified.\n */\nlibrary EnumerableMap {\n\tstruct Entry {\n\t\taddress key;\n\t\tuint16 value;\n\t}\n\n\tstruct Map {\n\t\tmapping (address => uint256) index;\n\t\tEntry[] entries;\n\t}\n\n\tfunction initialize(Map storage map) internal {\n\t\t// we initialize it with a placeholder entry in the first position because we treat the array as 1-indexed since 0 is a special index (means no entry in the index)\n\t\tmap.entries.push();\n\t}\n\n\tfunction contains(Map storage map, address key) internal view returns (bool) {\n\t\treturn map.index[key] != 0;\n\t}\n\n\tfunction set(Map storage map, address key, uint16 value) internal {\n\t\tuint256 index = map.index[key];\n\t\tif (index == 0) {\n\t\t\t// create new entry\n\t\t\tEntry memory entry = Entry({ key: key, value: value });\n\t\t\tmap.entries.push(entry);\n\t\t\tmap.index[key] = map.entries.length - 1;\n\t\t} else {\n\t\t\t// update existing entry\n\t\t\tmap.entries[index].value = value;\n\t\t}\n\n\t\trequire(map.entries[map.index[key]].key == key, \"Key at inserted location does not match inserted key.\");\n\t\trequire(map.entries[map.index[key]].value == value, \"Value at inserted location does not match inserted value.\");\n\t}\n\n\tfunction remove(Map storage map, address key) internal {\n\t\t// get the index into entries array that this entry lives at\n\t\tuint256 index = map.index[key];\n\n\t\t// if this key doesn't exist in the index, then we have nothing to do\n\t\tif (index == 0) return;\n\n\t\t// if the entry we are removing isn't the last, overwrite it with the last entry\n\t\tuint256 lastIndex = map.entries.length - 1;\n\t\tif (index != lastIndex) {\n\t\t\tEntry storage lastEntry = map.entries[lastIndex];\n\t\t\tmap.entries[index] = lastEntry;\n\t\t\tmap.index[lastEntry.key] = index;\n\t\t}\n\n\t\t// delete the last entry (if the item we are removing isn't last, it will have been overwritten with the last entry inside the conditional above)\n\t\tmap.entries.pop();\n\n\t\t// delete the index pointer\n\t\tdelete map.index[key];\n\n\t\trequire(map.index[key] == 0, \"Removed key still exists in the index.\");\n\t\trequire(index == lastIndex || map.entries[index].key != key, \"Removed key still exists in the array at original index.\");\n\t}\n\n\tfunction get(Map storage map, address key) internal view returns (uint16) {\n\t\tuint256 index = map.index[key];\n\t\trequire(index != 0, \"Provided key was not in the map.\");\n\t\treturn map.entries[index].value;\n\t}\n\n\t// this function is effectively map.entries.slice(1:), but that doesn't work with storage arrays in this version of solc so we have to do it by hand\n\tfunction enumerate(Map storage map) internal view returns (Entry[] memory) {\n\t\t// output array is one shorter because we use a 1-indexed array\n\t\tEntry[] memory output = new Entry[](map.entries.length - 1);\n\n\t\t// first element in the array is just a placeholder (0,0), so we copy from element 1 to end\n\t\tfor (uint256 i = 1; i < map.entries.length; ++i) {\n\t\t\toutput[i - 1] = map.entries[i];\n\t\t}\n\t\treturn output;\n\t}\n}\n\n/// @notice a smart wallet that is secured against loss of keys by way of backup keys that can be used to recover access with a time delay.\ncontract RecoverableWallet is Erc777TokensRecipient {\n\tusing EnumerableMap for EnumerableMap.Map;\n\n\tevent RecoveryAddressAdded(address indexed newRecoverer, uint16 recoveryDelayInDays);\n\tevent RecoveryAddressRemoved(address indexed oldRecoverer);\n\tevent RecoveryStarted(address indexed newOwner);\n\tevent RecoveryCancelled(address indexed oldRecoverer);\n\tevent RecoveryFinished(address indexed oldOwner, address indexed newOwner);\n\n\taddress public owner;\n\t/// @notice a collection of accounts that are able to recover control of this wallet, mapped to the number of days it takes for each to complete a recovery.\n\t/// @dev the recovery days are also used as a recovery priority, so a recovery address with a lower number of days has a higher recovery priority and can override a lower-priority recovery in progress.\n\tEnumerableMap.Map private recoveryDelaysInDays;\n\t/// @notice the address that is currently trying to recover access to the contract.\n\taddress public activeRecoveryAddress;\n\t/// @notice the time at which the activeRecoveryAddress can take ownership of the contract.\n\tuint256 public activeRecoveryEndTime = uint256(-1);\n\n\t/// @notice a function modifier that ensures the modified function can only be called by the owner of the contract.\n\tmodifier onlyOwner() {\n\t\trequire(msg.sender == owner, \"Only the owner may call this method.\");\n\t\t_;\n\t}\n\n\t/// @notice the modified function can only be called when the wallet is undergoing recovery.\n\tmodifier onlyDuringRecovery() {\n\t\trequire(activeRecoveryAddress != address(0), \"This method can only be called during a recovery.\");\n\t\t_;\n\t}\n\n\t/// @notice the modified function can only be called when the wallet is not undergoing recovery.\n\tmodifier onlyOutsideRecovery() {\n\t\trequire(activeRecoveryAddress == address(0), \"This method cannot be called during a recovery.\");\n\t\t_;\n\t}\n\n\tconstructor(address _initialOwner) public {\n\t\trequire(_initialOwner != address(0), \"Wallet must have an initial owner.\");\n\t\towner = _initialOwner;\n\t\trecoveryDelaysInDays.initialize();\n\t}\n\n\tfunction listRecoverers() external view returns (EnumerableMap.Entry[] memory) {\n\t\treturn recoveryDelaysInDays.enumerate();\n\t}\n\n\tfunction getRecoveryDelayInDays(address recoverer) external view returns (uint16) {\n\t\treturn recoveryDelaysInDays.get(recoverer);\n\t}\n\n\t/// @notice accept ETH transfers into this contract\n\treceive () external payable { }\n\n\t/// @notice add a new recovery address to the wallet with the specified number of day delay\n\t/// @param _newRecoveryAddress the address to be added\n\t/// @param _recoveryDelayInDays the number of days delay between when `_newRecoveryAddress` can initiate a recovery and when it can complete the recovery\n\tfunction addRecoveryAddress(address _newRecoveryAddress, uint16 _recoveryDelayInDays) external onlyOwner onlyOutsideRecovery {\n\t\trequire(_newRecoveryAddress != address(0), \"Recovery address must be supplied.\");\n\t\trecoveryDelaysInDays.set(_newRecoveryAddress, _recoveryDelayInDays);\n\t\temit RecoveryAddressAdded(_newRecoveryAddress, _recoveryDelayInDays);\n\t}\n\n\t/// @notice removes a recovery address from the collection, preventing it from being able to issue recovery operations in the future\n\t/// @param _oldRecoveryAddress the address to remove from the recovery addresses collection\n\tfunction removeRecoveryAddress(address _oldRecoveryAddress) public onlyOwner onlyOutsideRecovery {\n\t\trequire(_oldRecoveryAddress != address(0), \"Recovery address must be supplied.\");\n\t\trecoveryDelaysInDays.remove(_oldRecoveryAddress);\n\t\temit RecoveryAddressRemoved(_oldRecoveryAddress);\n\t}\n\n\t/// @notice starts the recovery process.  must be called by a previously registered recovery address.  recovery will complete in a number of days dependent on the address that initiated the recovery\n\tfunction startRecovery() external {\n\t\trequire(recoveryDelaysInDays.contains(msg.sender), \"Caller is not registered as a recoverer for this wallet.\");\n\t\tuint16 _proposedRecoveryDelayInDays = recoveryDelaysInDays.get(msg.sender);\n\n\t\tbool _inRecovery = activeRecoveryAddress != address(0);\n\t\tif (_inRecovery) {\n\t\t\t// NOTE: the delay for a particular recovery address cannot be changed during recovery nor can addresses be removed during recovery, so we can rely on this being != 0\n\t\t\tuint16 _activeRecoveryDelayInDays = recoveryDelaysInDays.get(activeRecoveryAddress);\n\t\t\trequire(_proposedRecoveryDelayInDays < _activeRecoveryDelayInDays, \"Recovery is already under way and new recoverer doesn't have a higher priority.\");\n\t\t\temit RecoveryCancelled(activeRecoveryAddress);\n\t\t}\n\n\t\tactiveRecoveryAddress = msg.sender;\n\t\tactiveRecoveryEndTime = block.timestamp + _proposedRecoveryDelayInDays * 1 days;\n\t\temit RecoveryStarted(msg.sender);\n\t}\n\n\t/// @notice cancels an active recovery.  can only be called by the current contract owner.  used to cancel a recovery in case the owner key is found\n\t/// @dev cancellation is only reliable if the recovery time has not elapsed\n\tfunction cancelRecovery() public onlyOwner onlyDuringRecovery {\n\t\taddress _recoveryAddress = activeRecoveryAddress;\n\t\tresetRecovery();\n\t\temit RecoveryCancelled(_recoveryAddress);\n\t}\n\n\t/// @notice cancels an active recovery and removes the recovery address from the recoverer collection.  used when a recovery key becomes compromised and attempts to initiate a recovery\n\tfunction cancelRecoveryAndRemoveRecoveryAddress() external onlyOwner onlyDuringRecovery {\n\t\taddress _recoveryAddress = activeRecoveryAddress;\n\t\tcancelRecovery();\n\t\tremoveRecoveryAddress(_recoveryAddress);\n\t}\n\n\t/// @notice finishes the recovery process after the necessary delay has elapsed.  callable by anyone in case the keys controlling the active recovery address have been lost, since once this is called a new recovery (with a potentially lower recovery priority) can begin.\n\tfunction finishRecovery() external onlyDuringRecovery {\n\t\trequire(block.timestamp >= activeRecoveryEndTime, \"You must wait until the recovery delay is over before finishing the recovery.\");\n\n\t\taddress _oldOwner = owner;\n\t\towner = activeRecoveryAddress;\n\t\tresetRecovery();\n\t\temit RecoveryFinished(_oldOwner, owner);\n\t}\n\n\t/// @notice deploy a contract from this contract.\n\t/// @dev uses create2, so the address of the deployed contract will be deterministic\n\t/// @param _value the amount of ETH that should be supplied to the contract creation call\n\t/// @param _data the deployment bytecode to execute\n\t/// @param _salt the salt used for deterministic contract creation.  see documentation at https://eips.ethereum.org/EIPS/eip-1014 for details on how the address is computed\n\tfunction deploy(uint256 _value, bytes calldata _data, uint256 _salt) external payable onlyOwner onlyOutsideRecovery returns (address) {\n\t\trequire(address(this).balance >= _value, \"Wallet does not have enough funds available to deploy the contract.\");\n\t\trequire(_data.length != 0, \"Contract deployment must contain bytecode to deploy.\");\n\t\tbytes memory _data2 = _data;\n\t\taddress newContract;\n\t\t/* solium-disable-next-line */\n\t\tassembly { newContract := create2(_value, add(_data2, 32), mload(_data2), _salt) }\n\t\trequire(newContract != address(0), \"Contract creation returned address 0, indicating failure.\");\n\t\treturn newContract;\n\t}\n\n\t/// @notice executes an arbitrary contract call by this wallet.  allows the wallet to send ETH, transfer tokens, use dapps, etc.\n\t/// @param _to contract address to call or send to\n\t/// @param _value the amount of ETH to attach to the call\n\t/// @param _data the calldata to supply to `_to`\n\t/// @dev `_data` is of the same form used to call a contract from the JSON-RPC API, so for Solidity contract calls it is the target function hash followed by the ABI encoded parameters for that function\n\tfunction execute(address payable _to, uint256 _value, bytes calldata _data) external payable onlyOwner onlyOutsideRecovery returns (bytes memory) {\n\t\trequire(_to != address(0), \"Transaction execution must contain a destination.  If you meant to deploy a contract, use deploy instead.\");\n\t\trequire(address(this).balance >= _value, \"Wallet does not have enough funds available to execute the desired transaction.\");\n\t\t(bool _success, bytes memory _result) = _to.call.value(_value)(_data);\n\t\trequire(_success, \"Contract execution failed.\");\n\t\treturn _result;\n\t}\n\n\tfunction resetRecovery() private {\n\t\tactiveRecoveryAddress = address(0);\n\t\tactiveRecoveryEndTime = uint256(-1);\n\t}\n}\n\n/// @notice A factory for creating new recoverable wallets.  this is useful because an event is fired anytime a wallet is created with this factory, so we can track all wallets created by this by monitoring contract events\ncontract RecoverableWalletFactory {\n\tevent WalletCreated(address indexed owner, RecoverableWallet indexed wallet);\n\n\t/// @notice creates a new recoverable wallet that is initially owned by the caller\n\tfunction createWallet() external returns (RecoverableWallet) {\n\t\tRecoverableWallet wallet = new RecoverableWallet(msg.sender);\n\t\temit WalletCreated(msg.sender, wallet);\n\t\treturn wallet;\n\t}\n\n\t/// @notice this function makes it so one can easily identify whether this contract has been deployed or not.  deployment of this factory is done deterministically, so it will live at a well known address on every chain but the user may need to check whether or not this contract has been deployed yet on a given chain\n\tfunction exists() external pure returns (bytes32) {\n\t\treturn 0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef;\n\t}\n}\n"
    }
  }
}}