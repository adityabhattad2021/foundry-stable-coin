// What are invarients for this smart contracts (Properties that always need to be true).

// 1. Total supply of the DSC should always be less than total value of the collateral deposited
// 2. Getter view functions should never revert.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;


import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract InvarientsTest is StdInvariant, Test{
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    HelperConfig helperConfig;
    address weth;
    address wbtc;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, helperConfig) = deployer.run();
        (, , weth, wbtc, ) = helperConfig.activeNetworkConfig();
        targetContract(address(dsce));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        uint256 totalSuply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsc));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsc));

        uint256 wEthValue = dsce.getUsdValue(weth,totalWethDeposited);
        uint256 wBtcValue = dsce.getUsdValue(wbtc,totalWbtcDeposited);

        assert(totalSuply <= wEthValue + wBtcValue);
    }
}