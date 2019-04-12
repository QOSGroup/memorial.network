pragma solidity ^0.5.4;
pragma experimental ABIEncoderV2;

import "./ID.sol";
import "./IERC20.sol";
import "./ISacrifice.sol";

contract SacrificeStore {

	address _MemorialContract;
	address _owner;

	constructor( ) public {
		_owner = msg.sender;
	}

	function setContract(address addr) public {
		require(msg.sender == _owner);
		_MemorialContract = addr;
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
