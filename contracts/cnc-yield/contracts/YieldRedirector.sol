// SPDX-License-Identifier: GNU Affero
pragma solidity ^0.6.0;

import {SafeERC20, SafeMath, IERC20, Address} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniLikeSwapRouter.sol";

interface IStrategy {
    function harvest() external;
}

interface IPotPool {
    function notifyRewardAmount(uint256 reward) external;
}

contract YieldRedirector is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // We recv excesss want tokens from a strategy
    // We then need to sell the tokens to our secondary want token, e.g. kllima
    // Finally we send the new tokens and call notifyRewardAmount on a SNX/harvest potpool style rewarder
    // Users can then claim their rewards from it.
    address public keeper;
    IERC20 public want2;
    IERC20 public want;
    IStrategy public underlyingStrategy;
    IPotPool public rewarderMasterchef;

    IUniLikeSwapRouter public constant SUSHI_ROUTER =
        IUniLikeSwapRouter(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
    IUniLikeSwapRouter public ROUTER;

    constructor(
        address _vault,
        IERC20 _want2,
        IERC20 _want,
        IStrategy _strat,
        IPotPool _potpool
    ) public {
        want2 = _want2;
        want = _want;
        // Get Decimals
        // DECIMALS = ERC20(address(want)).decimals();
        ROUTER = SUSHI_ROUTER;
        want.safeApprove(address(ROUTER), type(uint256).max);
        want2.safeApprove(address(ROUTER), type(uint256).max);

        underlyingStrategy = _strat;
        rewarderMasterchef = _potpool;
    }

    modifier onlyAuthorized() {
        require(msg.sender == keeper || msg.sender == owner(), "!authorized");
        _;
    }

    function setKeeper(address _keeper) external onlyAuthorized {
        require(_keeper != address(0));
        keeper = _keeper;
    }

    function harvest() public onlyAuthorized {
        // harvest to get tokens then swap tokens
        underlyingStrategy.harvest();
        uint256 bal = want.balanceOf(address(this));
        if (bal > 0) {
            _fromWant1ToWant2(bal, 0);
        }
        updateRewards();
    }

    function updateRewards() public onlyAuthorized {
        // send to rewarder and notify to update distribution rate
        uint256 bal2 = want2.balanceOf(address(this));
        if (bal2 > 0) {
            want2.safeTransfer(address(rewarderMasterchef), bal2);
            rewarderMasterchef.notifyRewardAmount(bal2);
        }
    }

    // Swap from AAVE to Want
    ///@param amountToSwap Amount of AAVE to Swap, NOTE: You have to calculate the amount!!
    ///@param multiplierInWei pricePerToken including slippage, will be divided by 10 ** 18
    function manualSwap(uint256 amountToSwap, uint256 multiplierInWei)
        public
        onlyAuthorized
    {
        uint256 amountOutMinimum = amountToSwap.mul(multiplierInWei).div(
            10**18
        );

        _fromWant1ToWant2(amountToSwap, amountOutMinimum);
    }

    function _fromWant1ToWant2(uint256 amountIn, uint256 minOut) internal {
        address[] memory path = new address[](2);
        path[0] = address(want);
        path[1] = address(want2);
        if (want2 != want) {
            ROUTER.swapExactTokensForTokens(
                amountIn,
                minOut,
                path,
                address(this),
                now
            );
        }
    }
}
