pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

import "./ISacrifice.sol";
import "./IERC20.sol";

contract MemorialParker {

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

	enum Relatives { MARRIAGE, FATHER, MOTHER, SON, DAUGHTER, OTHER}
	struct RelationData {
		string memorialID;
		string name;
		string otherRelation;
		Relatives rType;
	}
	mapping(string => mapping(uint => RelationData)) Relations; 
	mapping(string => uint) RelationCount;

	uint256 public currentNumber;

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
	) public notInMemorialPark(_id) {
		require(bytes(_id).length>=1 && bytes(_id).length<=128);
		require(bytes(_name).length > 0);
		MemorialPark[_id] = Memorial(_name, _nationality, bt, st, epitaph, pha, introduction, pic, true);
		currentNumber++;
		string[] storage _owned = MemorialOwner[msg.sender];
		string[] memory _tmp = new string[](_owned.length+1);
		for (uint i=0; i<_owned.length; i++) {
			_tmp[i] = _owned[i];
		}
		_tmp[_owned.length] = _id;
		MemorialOwner[msg.sender] = _tmp;
	}

	function updateMemorialName(string memory _id, string memory _name) public inMemorialPark(_id) ownedMemorial(_id) {
		Memorial memory _t = MemorialPark[_id];
		_t.name = _name;
		MemorialPark[_id] = _t;
	}

	//function updateMemorialbirthTime(string memory _id, uint256 bt) public inMemorialPark(_id) ownedMemorial(_id) {
	//	Memorial storage _t = MemorialPark[_id];
	//	_t.birthTime = bt;
	//	MemorialPark[_id] = _t;
	//}

	function updateMemorialsleepTime(string memory _id, string memory st) public inMemorialPark(_id) ownedMemorial(_id) {
		Memorial memory _t = MemorialPark[_id];
		_t.sleepTime = st;
		MemorialPark[_id] = _t;
	}

	function updateMemorialphyAddress(string memory _id, string memory _paddress) public inMemorialPark(_id) ownedMemorial(_id) {
		require(bytes(_paddress).length<200);
		Memorial memory _t = MemorialPark[_id];
		_t.phyAddress = _paddress;
		MemorialPark[_id] = _t;
	}

	//function updateMemorialEpitaph(string memory _id, string memory _epitaph) public inMemorialPark(_id) ownedMemorial(_id) {
	//	require(bytes(_epitaph).length<200);
	//	Memorial memory _t = MemorialPark[_id];
	//	_t.epitaph = _epitaph;
	//	MemorialPark[_id] = _t;
	//}

	function updateMemorialIntroduction(string memory _id, string memory _introduction) public inMemorialPark(_id) ownedMemorial(_id) {
		require(bytes(_introduction).length<2000);
		Memorial memory _t = MemorialPark[_id];
		_t.introduction = _introduction;
		MemorialPark[_id] = _t;
	}

	//function updateMemorialPicture(string memory _id, string memory _picture) public inMemorialPark(_id) ownedMemorial(_id) {
	//	require(bytes(_picture).length <4000);
	//	Memorial memory _t = MemorialPark[_id];
	//	_t.picture = _picture;
	//	MemorialPark[_id] = _t;
	//}

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

	function addManager(string memory _id, string memory _name, address _addr) public inMemorialPark(_id) ownedMemorial(_id){
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
		string memory _id2,
		string memory _name
	) public inMemorialPark(_id1) ownedMemorial(_id1) {
		require(_r >= Relatives.MARRIAGE && _r <= Relatives.OTHER);
		if (bytes(_name).length == 0) {
			require(MemorialPark[_id2].exist, "_id2 not in MemorialPark");
		}
		uint count = RelationCount[_id1];
		Relations[_id1][count] = RelationData("", _name, "", _r);
		if (MemorialPark[_id2].exist) {
			Relations[_id1][count].memorialID = _id2;
		}
		if (_r == Relatives.OTHER) {
			Relations[_id1][count].otherRelation = _otherRelation;
		}
		RelationCount[_id1] = count + 1;
	}

	function addRelationMulti(
		string[] memory _id1,
		Relatives[] memory _r,
		string[] memory _others,
		string[] memory _id2,
		string[] memory _name
	) public {
		require(_id1.length == _r.length, "Missmatched input lengths");
		require(_r.length == _id2.length, "Missmatched input lengths");
		require(_others.length == _id2.length, "Missmatched input lengths");
		require(_name.length == _others.length, "Missmatched input lengths");
		for (uint256 i=0; i<_id1.length; i++) {
			addRelation(_id1[i], _r[i], _others[i], _id2[i], _name[i]);
		}
	}

	//TODU:Add relation will charge fee
	// nogify memorial owner that request new relaions

	function getRelationCount(string memory _id) public view returns (uint) {
		return RelationCount[_id];
	}

	function getRelations(
		string memory _id
	) public view returns (Relatives[] memory, string[] memory, string[] memory, string[] memory) {
		uint num = RelationCount[_id];
		Relatives[] memory _r = new Relatives[](num);
		string[] memory _others = new string[](num);
		string[] memory _ids = new string[](num);
		string[] memory _names = new string[](num);
		for (uint i=0; i<num; i++) {
			_r[i] = Relations[_id][i].rType;
			_others[i] = Relations[_id][i].otherRelation;
			_ids[i] = Relations[_id][i].memorialID;
			_names[i] = Relations[_id][i].name;
		}

		return (_r, _others, _ids, _names);
	}

	//function deleteRelation(bytes32 _id1, Relation _r, bytes32 _id2) {
	//}


	//sacrifice
	mapping(uint => address) sacrifice_contract;
	mapping(address => address) sacrifice_owner;
	uint public sacrificeCount;

	function registerSacrifice(address _sacrificeContract) public {
		require(sacrifice_owner[_sacrificeContract] != address(0));
		string memory _sa = ISacrifice(_sacrificeContract).getSacrifice();
		require(bytes(_sa).length < 1000 && bytes(_sa).length>0, "sacrifice data is invalid");
		address _erc20;
		uint _price;
		(_erc20,_price) = ISacrifice(_sacrificeContract).getPrice();
		require(IERC20(_erc20).transferFrom(msg.sender, address(this), _price));
		require(IERC20(_erc20).approve(address(_sacrificeContract), _price));
		_sa = ISacrifice(_sacrificeContract).buySacrifice();
		require(bytes(_sa).length < 1000 && bytes(_sa).length>0, "sacrifice data is invalid");
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

	function getSacrifice(address _ad) public view returns (string memory) {
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
