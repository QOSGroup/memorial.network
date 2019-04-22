pragma solidity ^0.5.4;

contract RelationDeposit {

	mapping(address => uint) _deposit;
	address _owner1;
	address _owner2;
	address payable _withdraw1;
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

	function getDepositFee() public view returns (uint) {
		return _depositAmount;
	}

	function deposit(address _addr) payable public  {
		require(msg.sender == _contract);
		_deposit[_addr] = _deposit[_addr] + msg.value;
	}

	function withdraw(uint amount) public {
		require(msg.sender == _withdraw1 || msg.sender == _withdraw2);
		msg.sender.transfer(amount);
	}

	function getDeposit(address addr) public view returns (uint) {
		return _deposit[addr];
	}

	function takeDeposit(uint amount, address addr) public {
		require(msg.sender == _contract);
		require(amount <= _deposit[addr]);
		_deposit[addr] = _deposit[addr] - amount;
		_withdraw1.transfer(amount);
	}

	function refundDeposit(uint amount, address payable addr) public {
		require(msg.sender == _contract);
		require(amount <= _deposit[addr]);
		_deposit[addr] = _deposit[addr] - amount;
		addr.transfer(amount);

	}
}
