pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

import "./ID.sol";
import "./IERC20.sol";
import "./ISacrifice.sol";

contract MemorialParker {

	address _MemorialID;
	address _MemorialStore;
	address _RelationStore;
	address _SacrificeStore;
	address _owner;


	modifier inMemorialPark(string memory _id) {
		require(MemorialPark[_id].exist, "Memorial does not exist");
		_;
	}

	modifier notInMemorialPark(string memory _id) {
		require(!MemorialPark[_id].exist, "Memorial has existed");
		_;
	}
	
	modifier ownedMemorial(string memory _id) {
		bool flag = false;
		string[] memory _tmp = MemorialOwner[msg.sender];
		for (uint i=0; i<_tmp.length; i++){
			if (keccak256(abi.encodePacked(_id)) == keccak256(abi.encodePacked(_tmp[i]))) {
				flag = true;
			}
		}
		require(flag, "Not the Memorial owner");
		_;
	}

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
		MemorialStore(_MemorialStore).createMemorial(_name, _nationality, bt, st, epitaph, pha, introduction, pic, true, msg.sender);
	}

	function updateMemorial(
		string memory _id,
		string[] memory _key,
		string[] memory _value
	) public ownedMemorial(_id) {
		require(_key.length == _value.length);
		require(MemorialStore(_MemorialStore).isOwner(msg.sender, _id));
		MemorialStore(_MemorialStore).updateMemorial(_id, _key, _value);
	}

	function getMemorial(string memory _id) public view returns (
		string memory, string memory, string memory , string memory, string memory, string memory, string memory, string memory) {
		Memorial memory _t = MemorialPark[_id];
		return (_t.name, _t.nationality, _t.birthTime, _t.sleepTime, _t.epitaph, _t.phyAddress, _t.introduction, _t.picture);
	}

	function getOwnedMemorial() view public returns(string[] memory){
		return MemorialOwner[msg.sender];
	}

	//function deleteMemorial(string _id) {
	//}

	function addManager(string memory _id, string memory _name, address _addr) public ownedMemorial(_id){
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
	) public inMemorialPark(_id) ownedMemorial(_id) {
		require(_name.length == _addr.length);
		for (uint i=0; i<_name.length; i++) {
			addManager(_id, _name[i], _addr[i]);
		}
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

	//sacrifice
	mapping(uint => address) sacrifice_contract;
	mapping(address => address) sacrifice_owner;
	uint public sacrificeCount;

	function registerSacrifice(address _sacrificeContract) public {
		require(sacrifice_owner[_sacrificeContract] == address(0));
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
		sacrifice_contract[sacrificeCount] = _sacrificeContract;
		sacrificeCount++;
		sacrifice_owner[_sacrificeContract] = msg.sender;
		//transferfrom: charging fee
		//sacrifice_store[_t] = _a.push(s);
	}


	// return Contract Address of sacifice provider
	// address.getSacrifices(_t) returns the array of sacrifice
	// address.getSacrifice(id)
	// address.getPrice(id)
	// address.useSacrifice() {transferfrom()}
	// memory message
	function getSacrificeContract() public view returns (address[] memory) {
		address[] memory adds = new address[](sacrificeCount);
		for(uint i=0; i<sacrificeCount; i++){
			adds[i] = sacrifice_contract[i];
		}
		return adds;
	}

	function getSacrifice(address _ad) public view returns (string memory, string memory) {
		return ISacrifice(_ad).getSacrifice();
	}

	function getPrice(address _ad) public view returns (address, uint) {
		return ISacrifice(_ad).getPrice();
	}

	struct SacrificeHistory{
		string name;
		address addr;
		uint256 time;
		string message;
		string sacrifice;
	}
	mapping(string=>uint256) historyCounts;
	mapping(string=>mapping(uint256=>SacrificeHistory)) sHistory;


	function sacrifice(
		string memory _id,
		address _sacrificeContract,
		string memory _name,
		string memory _message
	) public inMemorialPark(_id) { 
		string memory _sa;
		require(bytes(_name).length<100);
		require(bytes(_message).length<500);
		if (_sacrificeContract != address(0)) {
			require(sacrifice_owner[_sacrificeContract] != address(0));
			address _erc20;
			uint _price;
			(_erc20, _price) = ISacrifice(_sacrificeContract).getPrice();
			require(IERC20(_erc20).transferFrom(msg.sender, address(this), _price));
			require(IERC20(_erc20).approve(_sacrificeContract, _price));
			_sa = ISacrifice(_sacrificeContract).buySacrifice();
			require(bytes(_sa).length < 1000, "sacrifice data is invalid");
		}
		uint256 n = historyCounts[_id];
		sHistory[_id][n]= SacrificeHistory(_name, msg.sender, now, _message, _sa);
		historyCounts[_id] = n+1;
	}

	function getSacrificeHistory(
		string memory _id
	) public inMemorialPark(_id) view returns (string[] memory, address[] memory, uint256[] memory, string[] memory, string[] memory) {
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
