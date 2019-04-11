pragma solidity ^0.5.4;

contract RelationDeposit {

	mapping(address => uint) _deposit;
	address _owner1;
	address _owner2;
	address _withdraw1;
	address _withdraw2;
	address _contract;

	uint _depositAmount;

	constructor() public{
		_owner1 = msg.sender;
		_withdraw1 = address(0x5306BAD23783536de290BCcb01e48fD75a0Cc3E5);
		_depositAmount = 100;
	}

	function updateContract(address addr) public {
		require(msg.sender == _owner1 || msg.sender == _owner2);
		require(addr != address(0));
		_contract = addr;
	}

	function updateWithdrawAddress(address addr) public {
		require(msg.sender == _owner1 || msg.sender == _owner2);
		require(addr != address(0));
		_withdraw2 = addr;
	}

	function updateDepositAmount(uint amt) public {
		require(msg.sender == _owner1 || msg.sender == _owner2);
		_depositAmount = amt;
	}

	function withdraw() public {
		require(msg.sender == _withdraw1 || msg.sender == _withdraw2);
		msg.sender.transfer(5);
	}

	function deposit() payable public  {
		_deposit[msg.sender] = msg.value;
	}

	function getDeposit(address addr) public view {
		return _deposit[addr];
	}

	function transfer(uint amount, address addr) public {
		require(msg.sender == _contract);
		addr.transfer(amount);

	}
}
