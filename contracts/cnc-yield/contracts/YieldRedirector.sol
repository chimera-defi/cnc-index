// SPDX-License-Identifier: Unlicensed


// Copyright (c) 2021 ChimeraDefi - All rights reserved
// Twitter: @ChimeraDefi

// Contract to redirect yield 
pragma solidity ^0.6.0;

import {SafeERC20, SafeMath, IERC20, Address} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IUniLikeSwapRouter.sol";

interface IStrategy {
    function harvest() external;
    function want() external returns (address);
}

// https://github.com/curvefi/multi-rewards/blob/master/contracts/MultiRewards.sol
interface IMutliRewards {
    function notifyRewardAmount(address _rewardsToken, uint256 reward) external;
}

contract YieldRedirector is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // We recv excesss want tokens from a strategy by calling harvest on it
    // We then need to sell the tokens to our secondary want token, e.g. kllima
    // Finally we send the new tokens and call notifyRewardAmount on a SNX/harvest potpool style rewarder
    // Users can then claim their rewards from it.
    address public keeper;
    IERC20 public target;
    IERC20 public want;
    IStrategy public underlyingStrategy;
    address public rewarder;

    IUniLikeSwapRouter public ROUTER;

    constructor(
        IERC20 _target,
        IStrategy _strat,
        address _router,
        address _rewarder // no check as this needs to be set later
    ) public {
        target = _target;
        keeper = msg.sender;
        ROUTER = IUniLikeSwapRouter(_router);

        underlyingStrategy = _strat;
        want = IERC20(underlyingStrategy.want());
        want.safeApprove(address(ROUTER), type(uint256).max);
        target.safeApprove(address(ROUTER), type(uint256).max);

        rewarder = _rewarder;
        target.safeApprove(_rewarder, type(uint256).max);
    }

    modifier onlyAuthorized() {
        require(msg.sender == keeper || msg.sender == owner(), "!authorized");
        _;
    }

    function setKeeper(address _keeper) external onlyAuthorized {
        require(_keeper != address(0));
        keeper = _keeper;
    }

    function setRewarder(address _rewarder) external onlyAuthorized {
        rewarder = _rewarder;
        target.safeApprove(rewarder, type(uint256).max);
    }

    function setStrategy(IStrategy _strategy) external onlyAuthorized {
        underlyingStrategy = _strategy;
    }

    function harvest() public onlyAuthorized {
        // harvest to get tokens then swap tokens
        underlyingStrategy.harvest();
        uint256 bal = want.balanceOf(address(this));
        if (bal > 0) {
            _fromWantToTarget(bal, 0);
        }
        updateRewards();
    }

    function updateRewards() public onlyAuthorized {
        // send to rewarder and notify to update distribution rate
        uint256 bal = target.balanceOf(address(this));
        if (bal > 0 && rewarder != address(0)) {
            IMutliRewards(rewarder).notifyRewardAmount(address(target), bal);
        }
    }

    // Swap from Want to target
    ///@param amountToSwap Amount of want to Swap, NOTE: You have to calculate the amount!!
    ///@param multiplierInWei pricePerToken including slippage, will be divided by 10 ** 18
    function manualSwap(uint256 amountToSwap, uint256 multiplierInWei)
        public
        onlyAuthorized
    {
        uint256 amountOutMinimum = amountToSwap.mul(multiplierInWei).div(
            10**18
        );

        _fromWantToTarget(amountToSwap, amountOutMinimum);
    }

    function recover(address token) external onlyAuthorized {
        IERC20(token).safeTransfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function _fromWantToTarget(uint256 amountIn, uint256 minOut) internal {
        address[] memory path = new address[](2);
        path[0] = address(want);
        path[1] = address(target);
        if (target != want && amountIn > 0) {
            ROUTER.swapExactTokensForTokens(
                amountIn,
                minOut,
                path,
                address(this),
                now + 100
            );
        }
    }
}
