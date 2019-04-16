pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

import "./Deposit.sol";
import "./ID.sol";
import "./IERC20.sol";
import "./ISacrifice.sol";
import "./MemorialStore.sol";
import "./RelationStore.sol";
import "./SacrificeStore.sol";

contract MemorialParker {

	address public _MemorialID;
	address public _MemorialStore;
	address public _RelationStore;
	address public _SacrificeStore;
	address public _RelationDeposit;
	address public _owner;

	constructor( ) public {
		_owner = msg.sender;
	}

	function setIDContract(address addr) public {
		require(msg.sender == _owner);
		_MemorialID = addr;
	}

	function setMemorialStore(address addr) public {
		require(msg.sender == _owner);
		_MemorialStore = addr;
	}
	function setRelationStore(address addr) public {
		require(msg.sender == _owner);
		_RelationStore = addr;
	}
	function setSacrificeStore(address addr) public {
		require(msg.sender == _owner);
		_SacrificeStore = addr;
	}

	function setRelationDeposit(address addr) public {
		require(msg.sender == _owner);
		_RelationDeposit = addr;
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
		string memory pic
	) public {
		require(bytes(_id).length>=1 && bytes(_id).length<=128);
		require(bytes(_name).length > 0);
		require(!MemorialStore(_MemorialStore).exists(_id));
		address a = MemorialID(_MemorialID).getMemorialID(_id);
		require(a == address(0) || a == msg.sender);
		MemorialID(_MemorialID).addMemorialID(_id, msg.sender);
		MemorialStore(_MemorialStore).createMemorial(_id, _name, _nationality, bt, st, epitaph, pha, introduction, pic, msg.sender);
	}

	function updateMemorial(
		string memory _id,
		string[] memory _key,
		string[] memory _value
	) public {
		require(_key.length == _value.length);
		require(MemorialStore(_MemorialStore).isOwner(msg.sender, _id));
		MemorialStore(_MemorialStore).updateMemorial(_id, _key, _value);
	}

	function getMemorial(string memory _id) public view returns (
		string memory, string memory, string memory , string memory, string memory, string memory, string memory, string memory) {
		return (MemorialStore(_MemorialStore).getMemorial(_id));
	}

	function getOwnedMemorial() view public returns(string[] memory){
		return MemorialStore(_MemorialStore).getOwnedMemorial(msg.sender);
	}

	//function deleteMemorial(string _id) {
	//}

	function addManager(string memory _id, string memory _name, address _addr) public {
		require(MemorialStore(_MemorialStore).isOwner(msg.sender, _id));
		MemorialStore(_MemorialStore).addManager(_id, _name, _addr);
	}

	function addManagerMulti(
		string memory _id,
		string[] memory _name,
		address[] memory _addr
	) public {
		require(_name.length == _addr.length);
		for (uint i=0; i<_name.length; i++) {
			addManager(_id, _name[i], _addr[i]);
		}
	}


	//relationship
	// enum Relatives { MARRIAGE, FATHER, MATHER, SON, DAUGHTER, OTHER};
	// mapping(string => (mapping(uint => RelationData))) Relations; 
	// mapping(string => uint) RelationCount;
	function _addRelation(
		string memory _id1,
		RelationStore.Relatives _r,
		string memory _otherRelation,
		string memory _id2
	) public {
		require(RelationStore(_RelationStore).isValid(_r));
		require(MemorialStore(_MemorialStore).isOwner(msg.sender, _id1));
		require(MemorialStore(_MemorialStore).exists(_id2));
		if (MemorialStore(_MemorialStore).isOwner(msg.sender, _id2)) {
			RelationStore(_RelationStore).addOwnedRelation(_id1, _r, _otherRelation, _id2);
		} else {
			RelationStore(_RelationStore).addRelation(_id1, _r, _otherRelation, _id2, msg.sender);
		}
	}

	function addRelationMulti(
		string[] memory _id1,
		RelationStore.Relatives[] memory _r,
		string[] memory _others,
		string[] memory _id2
	) public payable {
		require(_id1.length == _r.length);
		require(_r.length == _id2.length);
		require(_others.length == _id2.length);
		uint n;
		for (uint256 i=0; i<_id1.length; i++) {
			if (!MemorialStore(_MemorialStore).isOwner(msg.sender, _id2[i])) {
				n++;
			}
		}
		require(n*RelationDeposit(_RelationDeposit).getDepositFee() == msg.value);

		for (uint256 i=0; i<_id1.length; i++) {
			_addRelation(_id1[i], _r[i], _others[i], _id2[i]);
		}
		RelationDeposit(_RelationDeposit).deposit.value(msg.value)(msg.sender);
	}

	function acceptRelation(
		string memory _id1,
		RelationStore.Relatives _r,
		uint _idx,
		string memory _id2
	) public {
		require(MemorialStore(_MemorialStore).isOwner(msg.sender, _id2));
		string memory id2;
		RelationStore.Relatives r2;
		(id2, r2) = RelationStore(_RelationStore).getRelation(_id1, _idx);
		require(r2 == _r);
		require(keccak256(abi.encodePacked(_id2)) == keccak256(abi.encodePacked(id2)));
		RelationStore(_RelationStore).updateStatus(_id1, _idx, RelationStore.Status.APPROVED);
		address payable _addr = RelationStore(_RelationStore).getRequestSender(_id1, _id2);
		RelationStore(_RelationStore).deleteRequest(_id1, _id2);
		uint _fee = RelationDeposit(_RelationDeposit).getDepositFee();
		RelationDeposit(_RelationDeposit).refundDeposit(_fee, _addr);
	}

	function acceptRelationMulti(
		string[] memory _id1s,
		RelationStore.Relatives[] memory _rs,
		uint[] memory _idxs,
		string[] memory _id2s
	) public {
		require(_id1s.length == _rs.length);
		require(_rs.length == _idxs.length);
		require(_idxs.length == _id2s.length);
		for (uint256 i=0; i<_id1s.length; i++) {
			acceptRelation(_id1s[i], _rs[i], _idxs[i], _id2s[i]);
		}
	}

	function rejectRelation(
		string memory _id1,
		RelationStore.Relatives _r,
		uint _idx,
		string memory _id2
	) public  {
		require(MemorialStore(_MemorialStore).isOwner(msg.sender, _id2));
		string memory id2;
		RelationStore.Relatives r2;
		(id2, r2) = RelationStore(_RelationStore).getRelation(_id1, _idx);
		require(r2 == _r);
		require(keccak256(abi.encodePacked(_id2)) == keccak256(abi.encodePacked(id2)));
		RelationStore(_RelationStore).updateStatus(_id1, _idx, RelationStore.Status.REJECTED);
		address _addr = RelationStore(_RelationStore).getRequestSender(_id1, _id2);
		RelationStore(_RelationStore).deleteRequest(_id1, _id2);
		uint _fee = RelationDeposit(_RelationDeposit).getDepositFee();
		RelationDeposit(_RelationDeposit).takeDeposit(_fee, _addr);
	}

	function rejectRelationMulti(
		string[] memory _id1s,
		RelationStore.Relatives[] memory _rs,
		uint[] memory _idxs,
		string[] memory _id2s
	) public {
		require(_id1s.length == _rs.length);
		require(_rs.length == _idxs.length);
		require(_idxs.length == _id2s.length);
		for (uint256 i=0; i<_id1s.length; i++) {
			rejectRelation(_id1s[i], _rs[i], _idxs[i], _id2s[i]);
		}
	}

	function updateRelation(
		string memory _id1,
		uint _idx,
		string memory _others
	) public {
		require(MemorialStore(_MemorialStore).isOwner(msg.sender, _id1));
		require(RelationStore(_RelationStore).canUpdate(_id1, _idx));
		RelationStore(_RelationStore).updateRelation(_id1, _idx, _others);
	}

	function updateRelationMulti(
		string[] memory _ids,
		uint[] memory _idxs,
		string[] memory _others
	) public {
		require(_ids.length == _idxs.length);
		require(_idxs.length == _others.length);
		for (uint256 i=0; i<_ids.length; i++) {
			updateRelation(_ids[i], _idxs[i], _others[i]);
		}

	}

	//function approveRelation() {}
	//store_money

	function deleteRelation(string memory _id, uint _idx) public {
		require(MemorialStore(_MemorialStore).isOwner(msg.sender, _id));
		RelationStore(_RelationStore).deleteRelation(_id, _idx);
	}

	function deleteRelationMulti(string[] memory _ids, uint[] memory _idxs) public {
		require(_ids.length == _idxs.length);
		for (uint256 i=0; i<_ids.length; i++) {
			deleteRelation(_ids[i], _idxs[i]);
		}
	}

	//TODU:Add relation will charge fee
	// nogify memorial owner that request new relaions

	function getRelations(
		string memory _id
	) public view returns (
	RelationStore.Relatives[] memory,
	string[] memory, string[] memory,
	uint[] memory,
	RelationStore.Status[] memory) {
		return RelationStore(_RelationStore).getRelations(_id);
	}

	function getRequestRelations(string memory _id) public view returns (string[] memory, uint[] memory) {
		return RelationStore(_RelationStore).getRequestRelations(_id);
	}

	function registerSacrifice(address _sacrificeContract) public {
		require(!SacrificeStore(_SacrificeStore).exists(_sacrificeContract));
		string memory _sa;
		string memory _sn;
		(_sn, _sa) = ISacrifice(_sacrificeContract).getSacrifice();
		require(bytes(_sa).length < 1000 && bytes(_sa).length>0);
		address _erc20;
		uint _price;
		(_erc20,_price) = ISacrifice(_sacrificeContract).getPrice();
		require(IERC20(_erc20).transferFrom(msg.sender, address(this), _price));
		require(IERC20(_erc20).approve(address(_sacrificeContract), _price));
		_sa = ISacrifice(_sacrificeContract).buySacrifice();
		require(bytes(_sa).length < 1000 && bytes(_sa).length>0);
		SacrificeStore(_SacrificeStore).addSacrificeContract(_sacrificeContract, msg.sender);
	}

	function getSacrificeContract() public view returns (address[] memory) {
		return SacrificeStore(_SacrificeStore).getSacrificeContract();
	}

	function getSacrifice(address _ad) public view returns (string memory, string memory) {
		return ISacrifice(_ad).getSacrifice();
	}

	function getPrice(address _ad) public view returns (address, uint) {
		return ISacrifice(_ad).getPrice();
	}

	function sacrifice(
		string memory _id,
		address _sacrificeContract,
		string memory _name,
		string memory _message
	) public { 
		require(MemorialStore(_MemorialStore).exists(_id));
		string memory _sa;
		if (_sacrificeContract != address(0)) {
			require(SacrificeStore(_SacrificeStore).exists(_sacrificeContract));
			address _erc20;
			uint _price;
			(_erc20, _price) = ISacrifice(_sacrificeContract).getPrice();
			require(IERC20(_erc20).transferFrom(msg.sender, address(this), _price));
			require(IERC20(_erc20).approve(_sacrificeContract, _price));
			_sa = ISacrifice(_sacrificeContract).buySacrifice();
			require(bytes(_sa).length < 1000, "sacrifice data is invalid");
		}
		SacrificeStore(_SacrificeStore).addSacrificeHistory(_id, _name, msg.sender,  _message, _sa);
	}

	function getSacrificeHistory(
		string memory _id
	) public view returns (string[] memory, address[] memory, uint256[] memory, string[] memory, string[] memory) {
		return SacrificeStore(_SacrificeStore).getSacrificeHistory(_id);
	}
}
