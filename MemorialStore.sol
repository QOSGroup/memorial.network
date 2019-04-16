pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

import "./ID.sol";
import "./IERC20.sol";
import "./ISacrifice.sol";

contract MemorialStore {

	struct Memorial {
		string name;
		string nationality;
		string birthTime;
		string sleepTime;
		string epitaph;
		string phyAddress;
		string introduction;
		string picture;
		bool exist;
	}

	mapping(string => Memorial) MemorialPark;

	mapping(address => string[]) MemorialOwner;
	mapping(address => string) OwnerName;
	mapping(string => uint) _kv;
	address public _MemorialContract;
	address public _owner;
	uint256 public currentNumber;

	constructor() public {
		_kv["name"] = 1;
		_kv["nationality"] = 2;
		_kv["birthTime"] = 3;
		_kv["sleepTime"] = 4;
		_kv["epitaph"] = 5;
		_kv["phyAddress"] = 6;
		_kv["introduction"] = 7;
		_kv["picture"] = 8;
		_owner = msg.sender;
	}

	function setContract(address addr) public {
		require(msg.sender == _owner);
		_MemorialContract = addr;
	}

	function createMemorial(
		string memory _id,
		string memory _name,
		string memory _nationality,
		string memory bt,
		string memory st,
		string memory epitaph,
		string memory pha,
		string memory introduction,
		string memory pic,
		address _addr
	) public {
		require(msg.sender == _MemorialContract);
		MemorialPark[_id] = Memorial(_name, _nationality, bt, st, epitaph, pha, introduction, pic, true);
		currentNumber++;
		string[] storage _owned = MemorialOwner[_addr];
		string[] memory _tmp = new string[](_owned.length+1);
		for (uint i=0; i<_owned.length; i++) {
			_tmp[i] = _owned[i];
		}
		_tmp[_owned.length] = _id;
		MemorialOwner[_addr] = _tmp;
	}

	function exists(string memory _id) public view returns (bool) {
		return MemorialPark[_id].exist;
	}

	function isOwner(address _addr, string memory _id) public view returns (bool) {
		bool flag = false;
		string[] memory _tmp = MemorialOwner[_addr];
		for (uint i=0; i<_tmp.length; i++){
			if (keccak256(abi.encodePacked(_id)) == keccak256(abi.encodePacked(_tmp[i]))) {
				flag = true;
			}
		}
		return flag;
	}

	function updateMemorial(
		string memory _id,
		string[] memory _key,
		string[] memory _value
	) public {
		require(msg.sender == _MemorialContract);
		Memorial memory _t = MemorialPark[_id];
		for (uint i=0; i<_key.length; i++) {
			if (_kv[_key[i]] == 1) {
				_t.name = _value[i];
			}
			if (_kv[_key[i]] == 2) {
				_t.nationality = _value[i];
			}

			if (_kv[_key[i]] == 3) {
				_t.birthTime = _value[i];
			}
			if (_kv[_key[i]] == 4) {
				_t.sleepTime = _value[i];
			}
			if (_kv[_key[i]] == 5) {
				_t.epitaph = _value[i];
			}
			if (_kv[_key[i]] == 6) {
				_t.phyAddress = _value[i];
			}
			if (_kv[_key[i]] == 7) {
				_t.introduction = _value[i];
			}
			if (_kv[_key[i]] == 8) {
				_t.picture = _value[i];
			}
		}

		MemorialPark[_id] = _t;
	}

	function getMemorial(string memory _id) public view returns (
		string memory, string memory, string memory , string memory, string memory, string memory, string memory, string memory) {
		Memorial memory _t = MemorialPark[_id];
		return (_t.name, _t.nationality, _t.birthTime, _t.sleepTime, _t.epitaph, _t.phyAddress, _t.introduction, _t.picture);
	}

	function getOwnedMemorial(address _addr) view public returns(string[] memory){
		return MemorialOwner[_addr];
	}

	//function deleteMemorial(string _id) {
	//}

	function addManager(string memory _id, string memory _name, address _addr) public {
		require(msg.sender == _MemorialContract);
		string[] storage _owned = MemorialOwner[_addr];
		string[] memory _tmp = new string[](_owned.length+1);
		for (uint i=0; i<_owned.length; i++) {
			require(keccak256(abi.encodePacked(_id)) != keccak256(abi.encodePacked(_owned[i])));
			_tmp[i] = _owned[i];
		}
		_tmp[_owned.length] = _id;
		MemorialOwner[_addr] = _tmp;
		OwnerName[_addr] = _name;
	}

	function addManagerMulti(
		string memory _id,
		string[] memory _name,
		address[] memory _addr
	) public {
		require(msg.sender == _MemorialContract);
		require(_name.length == _addr.length);
		for (uint i=0; i<_name.length; i++) {
			addManager(_id, _name[i], _addr[i]);
		}
	}
}
