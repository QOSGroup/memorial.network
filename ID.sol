pragma solidity ^0.5.4;

contract MemorialID {

	mapping(string => address) ID;
	address _owner;
	address _contract;

	constructor() public{
		_owner = msg.sender;
	}

	function getMemorialID(string memory _id) public view returns (address) {
		return ID[_id];
	}

	function addMemorialID(string memory _id, address addr) public {
		require(msg.sender == _owner || msg.sender == _contract);
		require(addr != address(0));
		ID[_id] = addr;

	}

	function updateContract(address addr) public {
		require(msg.sender == _owner);
		require(addr != address(0));
		_contract = addr;
	}

}
