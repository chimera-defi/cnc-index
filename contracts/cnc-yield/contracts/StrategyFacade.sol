// SPDX-License-Identifier: GNU Affero
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IStrategyFacade.sol";
import {StrategyAPI} from "./BaseStrategy.sol";

/// @title Facade contract for Gelato Resolver contract
/// @author Tesseract Finance
contract StrategyFacade is IStrategyFacade, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal availableStrategies;
    address public resolver;
    uint256 public interval;
    uint256 public lastBlock;

    event StrategyAdded(address strategy);
    event StrategyRemoved(address strategy);
    event ResolverContractUpdated(address resolver);

    modifier onlyResolver {
        require(msg.sender == resolver, "StrategyFacade: Only Gelato Resolver can call");
        _;
    }

    function setResolver(address _resolver) public onlyOwner {
        resolver = _resolver;

        emit ResolverContractUpdated(_resolver);
    }

    function setInterval(uint256 _interval) public onlyOwner {
        interval = _interval;
    }

    function addStrategy(address _strategy) public onlyOwner {
        require(!availableStrategies.contains(_strategy), "StrategyFacade::addStrategy: Strategy already added");

        availableStrategies.add(_strategy);
        lastBlock = block.timestamp;

        emit StrategyAdded(_strategy);
    }

    function removeStrategy(address _strategy) public onlyOwner {
        require(availableStrategies.contains(_strategy), "StrategyFacade::removeStrategy: Strategy already removed");

        availableStrategies.remove(_strategy);

        emit StrategyRemoved(_strategy);
    }

    function gelatoCanHarvestAny(uint256 _callCost) public view {
        require(lastBlock+interval < block.timestamp);
        uint callable = 0;
        for (uint256 i; i < availableStrategies.length(); i++) {
            address currentStrategy = availableStrategies.at(i);
            if (StrategyAPI(currentStrategy).harvestTrigger(_callCost)) {
                callable++;
            }
        }
        require(callable > 0);
    }

    function harvestAll(uint256 _callCost) public onlyResolver {
        for (uint256 i; i < availableStrategies.length(); i++) {
            address currentStrategy = availableStrategies.at(i);
            if (StrategyAPI(currentStrategy).harvestTrigger(_callCost)) {
                harvest(currentStrategy);
            }
        }
        lastBlock = block.timestamp;
    }

    function checkHarvest(uint256 _callCost) public view override returns (bool canExec, address strategy) {
        for (uint256 i; i < availableStrategies.length(); i++) {
            address currentStrategy = availableStrategies.at(i);
            if (StrategyAPI(currentStrategy).harvestTrigger(_callCost)) {
                return (canExec = true, strategy = currentStrategy);
            }
        }

        return (canExec = false, strategy = address(0));
    }

    function harvest(address _strategy) public override onlyResolver {
        StrategyAPI(_strategy).harvest();
    }
}
