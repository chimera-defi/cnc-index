// SPDX-License-Identifier: Unlicensed

// Copyright (c) 2021 ChimeraDefi - All rights reserved
// Twitter: @ChimeraDefi

// Contract to redirect yield
pragma solidity ^0.6.0;

import {SafeERC20, SafeMath, IERC20, Address} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BaseStrategyInitializable, BaseStrategy} from "./BaseStrategy.sol";

abstract contract YieldRedirectStrategy is BaseStrategy {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // New for yield redirector
    uint256 private constant BLOCKS_PER_YEAR = 2_300_000;
    uint256 private constant MAX_BPS = 10_000;
    uint256 private constant SECS_PER_YEAR = 31_556_952;
    uint256 public lastSnapshotBlock;
    uint256 public targetAPR;
    address public masterChefRewarder;

    constructor(address _vault) public BaseStrategy(_vault) {
        lastSnapshotBlock = block.number;
    }

    // when we harvest we call the foll. fns in yearn strats: prepareReturn then adjustPosition
    // after prepareReturn, we want to redirect extra profit
    // in prepare return we get the value over target apr using _getValueOverTarget
    // then we redirect the yield to the masterChefRewarder address
    // masterChefRewarder - sell tokens, and deliver to a potpool snx style rewarder

    // remember to call setMasterChefRewarder as otherwise extra rewards get burnt
    // and set limit on vault
    // and set target apr

    // Call _setTargetAPR with onlyKeepers for yieldRedirect
    function setTargetAPR(uint256 newtarget) external onlyKeepers {
        targetAPR = newtarget;
    }

    // Call _setRewardProxy with onlyKeepers for yieldRedirect
    function setRewardProxy(address newMCR) external onlyKeepers {
        masterChefRewarder = newMCR;
    }

    function getRealAPR(uint256 _profit) public view returns (uint256) {
        uint256 diffTime = block.number.sub(lastSnapshotBlock);
        uint256 initialDeposit = vault.strategies(address(this)).totalDebt;
        if (initialDeposit == 0 || lastSnapshotBlock == 0) return 0;
        uint256 realApr = _profit
            .mul(BLOCKS_PER_YEAR)
            .div(diffTime)
            .mul(1e18)
            .div(initialDeposit);
        return realApr;
    }

    function getTargetAndDiff(uint256 _profit)
        public
        view
        returns (uint256 _diffToSell, uint256 _targetProfit)
    {
        uint256 diffTime = block.number.sub(lastSnapshotBlock);
        uint256 initialDeposit = vault.strategies(address(this)).totalDebt;

        _targetProfit = targetAPR.mul(diffTime).div(BLOCKS_PER_YEAR).mul(
            initialDeposit
        );
        _diffToSell = _profit.mul(1e18).sub(_targetProfit).div(1e18);
    }

    function getValueOverTarget(uint256 _profit, uint256 _loss)
        public
        view
        returns (uint256 _diffToSell, uint256 _targetProfit)
    {
        _targetProfit = _profit;
        if (_loss > 0 || _loss > _profit) {
            return (0, _profit);
        }

        // ((profit / principal) / blocks elapsed since last calc) * blocks in yr
        uint256 realApr = getRealAPR(_profit);

        if (realApr > targetAPR) {
            (_diffToSell, _targetProfit) = getTargetAndDiff(_profit);
        }
    }

    function _calcFees(uint256 gain) internal returns (uint256) {
        uint256 managementFee = vault.managementFee();
        uint256 performanceFee = vault.performanceFee();
        uint256 strategistFee = vault.strategies(address(this)).performanceFee;
        uint256 duration = block.timestamp -
            vault.strategies(address(this)).lastReport;

        uint256 management_fee = (
            (
                (vault.strategies(address(this)).totalDebt).mul(duration).mul( // This strat has 0 delegated assets
                        managementFee
                    )
            ).div(MAX_BPS).div(SECS_PER_YEAR)
        );
        uint256 performance_fee = gain.mul(performanceFee.div(MAX_BPS));
        uint256 govReward = management_fee.add(performance_fee);

        uint256 strategist_fee = (
            gain.mul(vault.strategies(address(this)).performanceFee).div(
                MAX_BPS
            )
        );

        if (strategist_fee > 0) {
            want.safeTransfer(strategist, strategist_fee);
        }
        if (govReward > 0) {
            want.safeTransfer(rewards, govReward);
        }
        return gain.sub(govReward.add(strategist_fee));
    }

    function _redirectExcessYield(uint256 _diffToSell) internal {
        require(masterChefRewarder != address(0));
        // since we skim before locking profits via a report we need to manually account for fees
        uint256 amountMinusFees = _calcFees(_diffToSell);
        if (amountMinusFees > 0) {
            want.safeTransfer(masterChefRewarder, amountMinusFees);
        }
    }

    // Main external hook to call from Strategy
    function _handleRedirect(uint256 _profit, uint256 _loss)
        internal
        returns (uint256 modifiedProfit)
    {
        // new yield redirect
        (uint256 toSell, uint256 earnedExcess) = getValueOverTarget(
            _profit,
            _loss
        );
        _redirectExcessYield(toSell);
        lastSnapshotBlock = block.number;
        modifiedProfit = earnedExcess;
    }
}
