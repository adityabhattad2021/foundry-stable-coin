// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/**
 * Layout of the contract
 * version
 * imports
 * errors
 * interfaces, libraries, and contracts
 * type declarations
 * state variables
 * events
 * modifiers
 * functions
 * 
 * layout of functions
 * constructor
 * receive function (if exists)
 * fallback function (if exists)
 * external functions
 * public functions
 * internal functions
 * private functions
 * view functions
 * pure functions
 * getters
 */

import {ERC20Burnable,ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
 
contract DecentralizedStableCoin is ERC20Burnable,Ownable{

    error DecentralizedStableCoin__AmountMustBeMoreThanZero();
    error DecentralizedStableCoin__InsufficientBalance();
    error DecentralizedStableCoin__NotZeroAddress();


    constructor() ERC20("DecentralizedStableCoin","DSC") Ownable(msg.sender) {
        
    }

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if(_amount <= 0){
            revert DecentralizedStableCoin__AmountMustBeMoreThanZero();
        }
        if(balance < _amount){
            revert DecentralizedStableCoin__InsufficientBalance();
        }
        super.burn(_amount);
    }

    function mint(address _to,uint256 _amount) external onlyOwner returns(bool) {
        if(_to==address(0)){
            revert DecentralizedStableCoin__NotZeroAddress();
        }
        if(_amount <= 0){
            revert DecentralizedStableCoin__AmountMustBeMoreThanZero();
        }
        _mint(_to,_amount);
        return true;
    }
}