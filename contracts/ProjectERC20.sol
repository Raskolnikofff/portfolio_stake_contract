pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProjectERC20 is ERC20, AccessControl {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function mint(address _address, uint256 _amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(_address, _amount);
    }
}
