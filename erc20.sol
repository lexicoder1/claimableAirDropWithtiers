pragma solidity 0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract erc20 is ERC20 {
    
    constructor() ERC20("",""){
      _mint(msg.sender,100000*10**18);
    }
}