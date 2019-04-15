pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

import "./ID.sol";
import "./IERC20.sol";
import "./ISacrifice.sol";

contract RelationStore {

	address _MemorialContract;
	address _owner;

	enum Relatives { MARRIAGE, FATHER, MOTHER, SON, DAUGHTER, OTHER}
	struct RelationData {
		string memorialID;
		string otherRelation;
		Relatives rType;
	}
	mapping(string => mapping(uint => RelationData)) Relations; 
	mapping(string => uint) RelationCount;



	constructor( ) public {
		_owner = msg.sender;
	}

	function setContract(address addr) public {
		require(msg.sender == _owner);
		_MemorialContract = addr;
	}

	//relationship
	// enum Relatives { MARRIAGE, FATHER, MATHER, SON, DAUGHTER, OTHER};
	// mapping(string => (mapping(uint => RelationData))) Relations; 
	// mapping(string => uint) RelationCount;
	function addRelation(
		string memory _id1,
		Relatives _r,
		string memory _otherRelation,
		string memory _id2
	) public inMemorialPark(_id1) inMemorialPark(_id2) ownedMemorial(_id1) {
		require(_r >= Relatives.MARRIAGE && _r <= Relatives.OTHER);
		uint count = RelationCount[_id1];
		Relations[_id1][count] = RelationData(_id2, "", _r);
		if (_r == Relatives.OTHER) {
			Relations[_id1][count].otherRelation = _otherRelation;
		}
		RelationCount[_id1] = count + 1;
	}

	function addRelationMulti(
		string[] memory _id1,
		Relatives[] memory _r,
		string[] memory _others,
		string[] memory _id2
	) public {
		require(_id1.length == _r.length);
		require(_r.length == _id2.length);
		require(_others.length == _id2.length);
		for (uint256 i=0; i<_id1.length; i++) {
			addRelation(_id1[i], _r[i], _others[i], _id2[i]);
		}
	}

	function updateRelation(
		string memory _id1,
		uint _idx,
		string memory _others
	) ownedMemorial(_id1) public {
		require(_idx <RelationCount[_id1]);
		require(Relations[_id1][_idx].rType == Relatives.OTHER);
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

	function deleteRelation(string memory _id, uint _idx) ownedMemorial(_id) public {
		require(_idx <RelationCount[_id]);
		delete Relations[_id][_idx];
	}

	function deleteRelationMulti(string[] memory _ids, uint[] memory _idxs) public {
		require(_ids.length == _idxs.length);
		for (uint256 i=0; i<_ids.length; i++) {
			deleteRelation(_ids[i], _idxs[i]);
		}
	}

	//TODU:Add relation will charge fee
	// nogify memorial owner that request new relaions

	function getRelationCount(string memory _id) public view returns (uint) {
		return RelationCount[_id];
	}

	function getRelations(
		string memory _id
	) public view returns (Relatives[] memory, string[] memory, string[] memory, uint[] memory) {
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
		n = 0;
		for (uint i=0; i<num; i++) {
			if (bytes(Relations[_id][i].memorialID).length != 0) {
				_r[n] = Relations[_id][i].rType;
				_others[n] = Relations[_id][i].otherRelation;
				_ids[n] = Relations[_id][i].memorialID;
				_idxs[n] = i;
				n++;
			}
		}

		return (_r, _others, _ids, _idxs);
	}

}
