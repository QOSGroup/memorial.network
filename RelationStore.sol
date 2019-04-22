pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

import "./ID.sol";
import "./IERC20.sol";
import "./ISacrifice.sol";

contract RelationStore {

	address _MemorialContract;
	address _owner;

	enum Relatives { MARRIAGE, FATHER, MOTHER, SON, DAUGHTER, OTHER}
	enum Status {REQUESTED, APPROVED, REJECTED}
	struct RelationData {
		string memorialID;
		string otherRelation;
		Relatives rType;
		Status status;
	}
	mapping(string => mapping(uint => RelationData)) Relations; 
	mapping(string => uint) RelationCount;
	struct RequestData {
		string memorialID;
		uint idx;
		address payable addr;
	}
	mapping(string => mapping(uint => RequestData)) RequestRelation;
	mapping(string => uint) RequestCount;


	constructor( ) public {
		_owner = msg.sender;
	}

	function setContract(address addr) public {
		require(msg.sender == _owner);
		_MemorialContract = addr;
	}

	function isValid(Relatives _r) public pure returns (bool) {
		return (_r >= Relatives.MARRIAGE && _r <= Relatives.OTHER);
	}

	function addOwnedRelation(
		string memory _id1,
		Relatives _r,
		string memory _otherRelation,
		string memory _id2
	) public {
		require(_MemorialContract == msg.sender);
		uint count = RelationCount[_id1];
		Relations[_id1][count] = RelationData(_id2, "", _r, Status.APPROVED);
		if (_r == Relatives.OTHER) {
			Relations[_id1][count].otherRelation = _otherRelation;
		}
		RelationCount[_id1] = count + 1;
	}

	function addRelation(
		string memory _id1,
		Relatives _r,
		string memory _otherRelation,
		string memory _id2,
		address payable _addr
	) public {
		require(_MemorialContract == msg.sender);
		uint count = RelationCount[_id1];
		Relations[_id1][count] = RelationData(_id2, "", _r, Status.REQUESTED);
		if (_r == Relatives.OTHER) {
			Relations[_id1][count].otherRelation = _otherRelation;
		}
		RelationCount[_id1] = count + 1;
		uint count1 = RequestCount[_id2];
		RequestRelation[_id2][count1] = RequestData(_id1, count, _addr);
		RequestCount[_id2] = count1 + 1;
	}

	function addRelationMulti(
		string[] memory _id1,
		Relatives[] memory _r,
		string[] memory _others,
		string[] memory _id2,
		address payable[] memory _addrs
	) public {
		require(_MemorialContract == msg.sender);
		require(_id1.length == _r.length);
		require(_r.length == _id2.length);
		require(_others.length == _id2.length);
		require(_id2.length == _addrs.length);
		for (uint256 i=0; i<_id1.length; i++) {
			addRelation(_id1[i], _r[i], _others[i], _id2[i], _addrs[i]);
		}
	}

	function deleteRequest(string memory _id1, string memory _id2) public {
		require(_MemorialContract == msg.sender);
		uint count = RequestCount[_id2];
		for (uint i=0; i<count; i++) {
			if (keccak256(abi.encodePacked(RequestRelation[_id2][i].memorialID)) == keccak256(abi.encodePacked(_id1))){
				delete RequestRelation[_id2][i];
				return;
			}
		}
	}


	function canUpdate(string memory _id, uint _idx) public view returns (bool) {
		return Relations[_id][_idx].rType == Relatives.OTHER;
	}

	function updateStatus(
		string memory _id1,
		uint _idx,
		Status _s
	) public {
		require(_MemorialContract == msg.sender);
		Relations[_id1][_idx].status = _s;
	}

	function updateRelation(
		string memory _id1,
		uint _idx,
		string memory _others
	) public {
		require(_MemorialContract == msg.sender);
		Relations[_id1][_idx].otherRelation = _others;
	}

	function updateRelationMulti(
		string[] memory _ids,
		uint[] memory _idxs,
		string[] memory _others
	) public {
		require(_MemorialContract == msg.sender);
		require(_ids.length == _idxs.length);
		require(_idxs.length == _others.length);
		for (uint256 i=0; i<_ids.length; i++) {
			updateRelation(_ids[i], _idxs[i], _others[i]);
		}

	}

	//function approveRelation() {}
	//store_money

	function deleteRelation(string memory _id, uint _idx) public {
		require(_MemorialContract == msg.sender);
		require(_idx <RelationCount[_id]);
		delete Relations[_id][_idx];
	}

	function deleteRelationMulti(string[] memory _ids, uint[] memory _idxs) public {
		require(_ids.length == _idxs.length);
		for (uint256 i=0; i<_ids.length; i++) {
			deleteRelation(_ids[i], _idxs[i]);
		}
	}

	function getRequestSender(string memory _id1, string memory _id2) public view returns (address payable) {
		uint count = RequestCount[_id2];
		for (uint i=0; i<count; i++) {
			if (keccak256(abi.encodePacked(RequestRelation[_id2][i].memorialID)) == keccak256(abi.encodePacked(_id1))){
				return RequestRelation[_id2][i].addr;
			}
		}
	}

	function getRequestRelations(string memory _id) public view returns (string[] memory, uint[] memory) {
		uint count = RequestCount[_id];
		string[] memory _ids = new string[](count);
		uint[] memory _idxs = new uint[](count);
		for (uint i=0; i<count; i++) {
			_ids[i] = RequestRelation[_id][i].memorialID;
			_idxs[i] = RequestRelation[_id][i].idx;
		}
		return (_ids, _idxs);
	}

	function getRelation(string memory _id, uint _idx) public view returns (string memory, Relatives) {
		require(_MemorialContract == msg.sender);
		require(_idx <RelationCount[_id]);
		return (Relations[_id][_idx].memorialID, Relations[_id][_idx].rType);
	}

	function getRelationCount(string memory _id) public view returns (uint) {
		return RelationCount[_id];
	}

	function getRelations(
		string memory _id
	) public view returns (Relatives[] memory, string[] memory, string[] memory, uint[] memory, Status[] memory) {
		uint num = RelationCount[_id];
		uint n = 0;
		for (uint i=0; i<num; i++) {
			if (bytes(Relations[_id][i].memorialID).length != 0) {
				n++;
			}
		}
		Relatives[] memory _r = new Relatives[](n);
		string[] memory _others = new string[](n);
		string[] memory _ids = new string[](n);
		uint[] memory _idxs = new uint[](n);
		Status[] memory _status = new Status[](n);
		n = 0;
		for (uint i=0; i<num; i++) {
			if (bytes(Relations[_id][i].memorialID).length != 0) {
				_r[n] = Relations[_id][i].rType;
				_others[n] = Relations[_id][i].otherRelation;
				_ids[n] = Relations[_id][i].memorialID;
				_idxs[n] = i;
				_status[n] = Relations[_id][i].status;
				n++;
			}
		}

		return (_r, _others, _ids, _idxs, _status);
	}

	function getRelationStatus(string memory _id, uint _idx) public view returns (Status) {
		require(_MemorialContract == msg.sender);
		require(_idx <RelationCount[_id]);
		return Relations[_id][_idx].status;
	}

}
