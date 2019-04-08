pragma solidity ^0.5.1;

import "./IERC20.sol";
import "./ISacrifice.sol";

contract FlowerSacrifice is ISacrifice {
	uint private _price;
	address private _erc20Address;
	string private _flower;
	address public _owner;

	constructor(address _ad, uint _p) public {
		_erc20Address = _ad;
		_price = _p;
		_owner = msg.sender;
	}

	function updatePrice(address _ad, uint _p) public {
		require(_ad != address(0));
		require(_owner == msg.sender);
		_erc20Address = _ad;
		_price = _p;
	}

	function updateFlower(string memory _f) public {
		require(_owner == msg.sender);
		require(bytes(_f).length<1000 && bytes(_f).length>0);
		_flower = _f;
	}

	function getSacrifice() external view returns (string memory ){
		return _flower;
	}

	function getPrice() external view returns (address, uint) {
		return (_erc20Address, _price);
	}

	function buySacrifice() external returns (string memory) {
		require(IERC20(_erc20Address).transferFrom(msg.sender, address(this), _price));
		return _flower;
	}

	function withdrawTokens(uint num) public {
		require(_owner == msg.sender);
		require(IERC20(_erc20Address).transfer(msg.sender, num)); 
	}

}
