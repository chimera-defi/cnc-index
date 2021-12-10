// SPDX-License-Identifier: Unlicensed

// Copyright (c) 2021 ChimeraDefi - All rights reserved
// Twitter: @ChimeraDefi

// Contract to redirect yield
pragma solidity ^0.6.0;

import {SafeERC20, SafeMath, IERC20, Address} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BaseStrategyInitializable, BaseStrategy} from "./BaseStrategy.sol";

abstract contract YieldRedirectStrategyBase is BaseStrategyInitializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // New for yield redirector
    uint256 private constant MAX_BPS = 10_000;
    uint256 private constant SECS_PER_YEAR = 31_556_952;
    uint256 public targetAPR; // example - 12% => 1200
    address public masterChefRewarder;

    constructor(address _vault) public BaseStrategyInitializable(_vault) {}

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

    function getRealAPR(
        uint256 _profit,
        uint256 duration,
        uint256 totalDeposits
    ) public view returns (uint256 realApr) {
        realApr = _profit
            .mul(SECS_PER_YEAR)
            .mul(MAX_BPS)
            .div(duration)
            .div(totalDeposits);
    }

    function getTargetAndDiff(
        uint256 _profit,
        uint256 duration,
        uint256 totalDeposits
    ) public view returns (uint256 _diffToSell, uint256 _targetProfit) {
        _targetProfit = targetAPR.mul(duration).mul(totalDeposits).div(
            SECS_PER_YEAR
        );
        _diffToSell = _profit.mul(1e18).sub(_targetProfit).div(1e18);
    }

    function getElapsedDuration() public view returns (uint256 duration) {
        duration = block.timestamp - vault.strategies(address(this)).lastReport;
    }

    function getValueOverTarget(uint256 _profit, uint256 _loss)
        public
        view
        returns (uint256 _diffToSell, uint256 _targetProfit)
    {
        _targetProfit = _profit;

        // Pessimisticly forfeit profit if we have any losses
        if (_loss > 0 || _loss > _profit || _profit == 0) {
            return (0, _profit);
        }

        // This 2 values will change when the entire flow is run via harvest since harvest calls report on the vault
        uint256 totalDeposits = vault.strategies(address(this)).totalDebt;
        uint256 duration = getElapsedDuration(); // make debugging a bit easier

        if (totalDeposits == 0 || duration == 0) {
            return (0, _profit); // shouldnt be able to get here theoretically
        }

        // ((profit / principal) / blocks elapsed since last calc) * blocks in yr
        uint256 realApr = getRealAPR(_profit, duration, totalDeposits);

        if (realApr > targetAPR) {
            (_diffToSell, _targetProfit) = getTargetAndDiff(
                _profit,
                duration,
                totalDeposits
            );
        }
    }

    function _getFees(
        uint256 gain
    ) public view returns (uint256 govFee, uint256 strategistFee) {
        uint256 totalDeposits = vault.strategies(address(this)).totalDebt;
        uint256 duration = getElapsedDuration(); // make debugging a bit easier
        uint256 managementFee = vault.managementFee();
        uint256 performanceFee = vault.performanceFee();
        uint256 management_fee = (
            (
                (totalDeposits).mul(duration).mul(
                    // This strat has 0 delegated assets so this differs slightly from the impl in a vault
                    managementFee
                )
            ).div(MAX_BPS).div(SECS_PER_YEAR)
        );
        uint256 performance_fee = gain.mul(performanceFee.div(MAX_BPS));
        govFee = management_fee.add(performance_fee);

        strategistFee = (
            gain.mul(vault.strategies(address(this)).performanceFee).div(
                MAX_BPS
            )
        );

        // Note: - we have to handle fees this way in addition to normal vault fee handling
        // since the strategy redirects profits, and target profits could be 0
        // Downside is this leaves fees from accruing yield as is the normal case
        // if (strategist_fee > 0) {
        //     want.safeTransfer(strategist, strategist_fee);
        // }
        // if (govReward > 0) {
        //     want.safeTransfer(rewards, govReward);
        // }

        // return gain.sub(govReward.add(strategist_fee));
    }

    function _redirectExcessYield(uint256 _diffToSell, uint256 govFee, uint256 strategistFee) internal {
        require(masterChefRewarder != address(0));

        if (strategistFee > 0) {
            want.safeTransfer(strategist, strategistFee);
        }
        if (govFee > 0) {
            want.safeTransfer(rewards, govFee);
        }
        if (_diffToSell > 0) {
            want.safeTransfer(masterChefRewarder, _diffToSell);
        }
    }

    // Main external hook to call from Strategy
    // Needs to be called before prepareReturn in the strategy so profits are redirected
    // And called at least before the vault report
    function _handleRedirect(uint256 _profit, uint256 _loss)
        internal
        returns (uint256 modifiedProfit)
    {

        (uint256 govFee, uint256 strategistFee) = _getFees(_profit);
        uint256 profitPostFees = _profit.sub(govFee).sub(strategistFee);
        // new yield redirect
        (uint256 toSell, uint256 earnedExcess) = getValueOverTarget(
            profitPostFees,
            _loss
        );

        _redirectExcessYield(toSell, govFee, strategistFee);
        modifiedProfit = earnedExcess;
    }
}
