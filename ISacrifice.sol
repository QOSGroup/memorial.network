pragma solidity ^0.5.4;

interface ISacrifice {
	function getSacrifice() external view returns (string memory);

	function getPrice() external view returns (address, uint);

	function buySacrifice() external returns (string memory);

}
