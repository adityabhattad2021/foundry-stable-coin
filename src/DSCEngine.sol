// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DSCEngine is ReentrancyGuard {
    // Errors //
    error DSCEngine__AmountMustBeMoreThanZero();
    error DSCEngine__TokenNotSupported();
    error DSCEngine__TransferFailed();
    error DSCEngine__Constructor__TokenAndPriceFeedLengthMismatch();

    // State Variables //
    DecentralizedStableCoin private immutable i_dscAddress;
    mapping(address colletralToken => address priceFeed) private s_priceFeeds;
    mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;


    // Events //
    event CollateralDeposited(address indexed user, address indexed token, uint256 amount);

    // Modifiers //
    modifier amountMustBeMoreThanZero(uint256 _amount) {
        if (_amount <= 0) {
            revert DSCEngine__AmountMustBeMoreThanZero();
        }
        _;
    }

    modifier tokenSupported(address _tokenAddress) {
        if (s_priceFeeds[_tokenAddress] == address(0)) {
            revert DSCEngine__TokenNotSupported();
        }
        _;
    }

    // Functions //

    constructor(address _dscAddress, address[] memory tokenAddresses, address[] memory priceFeedAddresses) {
        if (tokenAddresses.length != priceFeedAddresses.length) {
            revert DSCEngine__Constructor__TokenAndPriceFeedLengthMismatch();
        }
        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            s_priceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
        }
        i_dscAddress = DecentralizedStableCoin(_dscAddress);
    }

    /**
     *
     * @param tokenColletralAddress The ERC20 token address of the collateral you are depositing
     * @param amountCollateral amount of collateral you are depositing
     * @param amountDscToMint the amount of DSC you want to mint
     * @notice this function will deposit your collateral and mint DSC in one transaction
     */
    function depositCollateralAndMintDsc(
        address tokenColletralAddress,
        uint256 amountCollateral,
        uint256 amountDscToMint
    ) external {}

    function depositCollateral(address tokenCollateralAddress, uint256 amountCollateral)
        public
        nonReentrant
        amountMustBeMoreThanZero(amountCollateral)
        tokenSupported(tokenCollateralAddress)
    {
        s_collateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
        emit CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);

        bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);
        if (!success) {
            revert DSCEngine__TransferFailed();
        }
    }
}
