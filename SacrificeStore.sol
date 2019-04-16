pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

import "./ID.sol";
import "./IERC20.sol";
import "./ISacrifice.sol";

contract SacrificeStore {

	address _MemorialContract;
	address _owner;
	mapping(uint => address) sacrifice_contract;
	mapping(address => address) sacrifice_owner;
	uint public sacrificeCount;
	struct SacrificeHistory{
		string name;
		address addr;
		uint256 time;
		string message;
		string sacrifice;
	}
	mapping(string=>uint256) historyCounts;
	mapping(string=>mapping(uint256=>SacrificeHistory)) sHistory;

	constructor( ) public {
		_owner = msg.sender;
	}

	function setContract(address addr) public {
		require(msg.sender == _owner);
		_MemorialContract = addr;
	}


	function exists(address _addr) public view returns (bool) {
		return sacrifice_owner[_addr] != address(0);
	}

	function addSacrificeContract(address _sacrificeContract, address _addr) public {
		require(_MemorialContract == msg.sender);
		sacrifice_contract[sacrificeCount] = _sacrificeContract;
		sacrificeCount++;
		sacrifice_owner[_sacrificeContract] = _addr;
	}


	function getSacrificeContract() public view returns (address[] memory) {
		address[] memory adds = new address[](sacrificeCount);
		for(uint i=0; i<sacrificeCount; i++){
			adds[i] = sacrifice_contract[i];
		}
		return adds;
	}


	function addSacrificeHistory(
		string memory _id,
		string memory _name,
		address _addr,
		string memory _message,
		string memory _sa
	) public { 
		require(_MemorialContract == msg.sender);
		uint256 n = historyCounts[_id];
		sHistory[_id][n]= SacrificeHistory(_name, _addr, now, _message, _sa);
		historyCounts[_id] = n+1;
	}

	function getSacrificeHistory(
		string memory _id
	) public view returns (string[] memory, address[] memory, uint256[] memory, string[] memory, string[] memory) {
		uint256 num = historyCounts[_id];
		string[] memory _name = new string[](num);
		address[] memory _addr = new address[](num);
		uint256[] memory _time = new uint256[](num);
		string[] memory _message = new string[](num);
		string[] memory _sacrifice = new string[](num);
		for (uint i=0; i<num; i++) {
			_name[i] = sHistory[_id][i].name;
			_addr[i] = sHistory[_id][i].addr;
			_time[i] = sHistory[_id][i].time;
			_message[i] = sHistory[_id][i].message;
			_sacrifice[i] = sHistory[_id][i].sacrifice;
		}
		return (_name, _addr, _time, _message, _sacrifice);
	}
}
