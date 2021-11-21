/**
 *Submitted for verification at polygonscan.com on 2021-09-03
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

// File: @aave/protocol-v2/contracts/interfaces/ILendingPoolAddressesProvider.sol
/**
 * @title LendingPoolAddressesProvider contract
 * @dev Main registry of addresses part of or connected to the protocol, including permissioned roles
 * - Acting also as factory of proxies and admin of those, so with right to change its implementations
 * - Owned by the Aave Governance
 * @author Aave
 **/
interface ILendingPoolAddressesProvider {
  event MarketIdSet(string newMarketId);
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function getMarketId() external view returns (string memory);

  function setMarketId(string calldata marketId) external;

  function setAddress(bytes32 id, address newAddress) external;

  function setAddressAsProxy(bytes32 id, address impl) external;

  function getAddress(bytes32 id) external view returns (address);

  function getLendingPool() external view returns (address);

  function setLendingPoolImpl(address pool) external;

  function getLendingPoolConfigurator() external view returns (address);

  function setLendingPoolConfiguratorImpl(address configurator) external;

  function getLendingPoolCollateralManager() external view returns (address);

  function setLendingPoolCollateralManager(address manager) external;

  function getPoolAdmin() external view returns (address);

  function setPoolAdmin(address admin) external;

  function getEmergencyAdmin() external view returns (address);

  function setEmergencyAdmin(address admin) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address priceOracle) external;

  function getLendingRateOracle() external view returns (address);

  function setLendingRateOracle(address lendingRateOracle) external;
}

// File: @aave/protocol-v2/contracts/interfaces/ILendingPool.sol
interface ILendingPool {
  /**
   * @dev Emitted on deposit()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address initiating the deposit
   * @param onBehalfOf The beneficiary of the deposit, receiving the aTokens
   * @param amount The amount deposited
   * @param referral The referral code used
   **/
  event Deposit(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint16 indexed referral
  );

  /**
   * @dev Emitted on withdraw()
   * @param reserve The address of the underlyng asset being withdrawn
   * @param user The address initiating the withdrawal, owner of aTokens
   * @param to Address that will receive the underlying
   * @param amount The amount to be withdrawn
   **/
  event Withdraw(address indexed reserve, address indexed user, address indexed to, uint256 amount);

  /**
   * @dev Emitted on borrow() and flashLoan() when debt needs to be opened
   * @param reserve The address of the underlying asset being borrowed
   * @param user The address of the user initiating the borrow(), receiving the funds on borrow() or just
   * initiator of the transaction on flashLoan()
   * @param onBehalfOf The address that will be getting the debt
   * @param amount The amount borrowed out
   * @param borrowRateMode The rate mode: 1 for Stable, 2 for Variable
   * @param borrowRate The numeric rate at which the user has borrowed
   * @param referral The referral code used
   **/
  event Borrow(
    address indexed reserve,
    address user,
    address indexed onBehalfOf,
    uint256 amount,
    uint256 borrowRateMode,
    uint256 borrowRate,
    uint16 indexed referral
  );

  /**
   * @dev Emitted on repay()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The beneficiary of the repayment, getting his debt reduced
   * @param repayer The address of the user initiating the repay(), providing the funds
   * @param amount The amount repaid
   **/
  event Repay(
    address indexed reserve,
    address indexed user,
    address indexed repayer,
    uint256 amount
  );

  /**
   * @dev Emitted on swapBorrowRateMode()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user swapping his rate mode
   * @param rateMode The rate mode that the user wants to swap to
   **/
  event Swap(address indexed reserve, address indexed user, uint256 rateMode);

  /**
   * @dev Emitted on setUserUseReserveAsCollateral()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user enabling the usage as collateral
   **/
  event ReserveUsedAsCollateralEnabled(address indexed reserve, address indexed user);

  /**
   * @dev Emitted on setUserUseReserveAsCollateral()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user enabling the usage as collateral
   **/
  event ReserveUsedAsCollateralDisabled(address indexed reserve, address indexed user);

  /**
   * @dev Emitted on rebalanceStableBorrowRate()
   * @param reserve The address of the underlying asset of the reserve
   * @param user The address of the user for which the rebalance has been executed
   **/
  event RebalanceStableBorrowRate(address indexed reserve, address indexed user);

  /**
   * @dev Emitted on flashLoan()
   * @param target The address of the flash loan receiver contract
   * @param initiator The address initiating the flash loan
   * @param asset The address of the asset being flash borrowed
   * @param amount The amount flash borrowed
   * @param premium The fee flash borrowed
   * @param referralCode The referral code used
   **/
  event FlashLoan(
    address indexed target,
    address indexed initiator,
    address indexed asset,
    uint256 amount,
    uint256 premium,
    uint16 referralCode
  );

  /**
   * @dev Emitted when the pause is triggered.
   */
  event Paused();

  /**
   * @dev Emitted when the pause is lifted.
   */
  event Unpaused();

  /**
   * @dev Emitted when a borrower is liquidated. This event is emitted by the LendingPool via
   * LendingPoolCollateral manager using a DELEGATECALL
   * This allows to have the events in the generated ABI for LendingPool.
   * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
   * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
   * @param user The address of the borrower getting liquidated
   * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
   * @param liquidatedCollateralAmount The amount of collateral received by the liiquidator
   * @param liquidator The address of the liquidator
   * @param receiveAToken `true` if the liquidators wants to receive the collateral aTokens, `false` if he wants
   * to receive the underlying collateral asset directly
   **/
  event LiquidationCall(
    address indexed collateralAsset,
    address indexed debtAsset,
    address indexed user,
    uint256 debtToCover,
    uint256 liquidatedCollateralAmount,
    address liquidator,
    bool receiveAToken
  );

  /**
   * @dev Emitted when the state of a reserve is updated. NOTE: This event is actually declared
   * in the ReserveLogic library and emitted in the updateInterestRates() function. Since the function is internal,
   * the event will actually be fired by the LendingPool contract. The event is therefore replicated here so it
   * gets added to the LendingPool ABI
   * @param reserve The address of the underlying asset of the reserve
   * @param liquidityRate The new liquidity rate
   * @param stableBorrowRate The new stable borrow rate
   * @param variableBorrowRate The new variable borrow rate
   * @param liquidityIndex The new liquidity index
   * @param variableBorrowIndex The new variable borrow index
   **/
  event ReserveDataUpdated(
    address indexed reserve,
    uint256 liquidityRate,
    uint256 stableBorrowRate,
    uint256 variableBorrowRate,
    uint256 liquidityIndex,
    uint256 variableBorrowIndex
  );

  /**
   * @dev Deposits an `amount` of underlying asset into the reserve, receiving in return overlying aTokens.
   * - E.g. User deposits 100 USDC and gets in return 100 aUSDC
   * @param asset The address of the underlying asset to deposit
   * @param amount The amount to be deposited
   * @param onBehalfOf The address that will receive the aTokens, same as msg.sender if the user
   *   wants to receive them on his own wallet, or a different address if the beneficiary of aTokens
   *   is a different wallet
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   **/
  function deposit(
    address asset,
    uint256 amount,
    address onBehalfOf,
    uint16 referralCode
  ) external;

  /**
   * @dev Withdraws an `amount` of underlying asset from the reserve, burning the equivalent aTokens owned
   * E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
   * @param asset The address of the underlying asset to withdraw
   * @param amount The underlying amount to be withdrawn
   *   - Send the value type(uint256).max in order to withdraw the whole aToken balance
   * @param to Address that will receive the underlying, same as msg.sender if the user
   *   wants to receive it on his own wallet, or a different address if the beneficiary is a
   *   different wallet
   * @return The final amount withdrawn
   **/
  function withdraw(
    address asset,
    uint256 amount,
    address to
  ) external returns (uint256);

  /**
   * @dev Allows users to borrow a specific `amount` of the reserve underlying asset, provided that the borrower
   * already deposited enough collateral, or he was given enough allowance by a credit delegator on the
   * corresponding debt token (StableDebtToken or VariableDebtToken)
   * - E.g. User borrows 100 USDC passing as `onBehalfOf` his own address, receiving the 100 USDC in his wallet
   *   and 100 stable/variable debt tokens, depending on the `interestRateMode`
   * @param asset The address of the underlying asset to borrow
   * @param amount The amount to be borrowed
   * @param interestRateMode The interest rate mode at which the user wants to borrow: 1 for Stable, 2 for Variable
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   * @param onBehalfOf Address of the user who will receive the debt. Should be the address of the borrower itself
   * calling the function if he wants to borrow against his own collateral, or the address of the credit delegator
   * if he has been given credit delegation allowance
   **/
  function borrow(
    address asset,
    uint256 amount,
    uint256 interestRateMode,
    uint16 referralCode,
    address onBehalfOf
  ) external;

  /**
   * @notice Repays a borrowed `amount` on a specific reserve, burning the equivalent debt tokens owned
   * - E.g. User repays 100 USDC, burning 100 variable/stable debt tokens of the `onBehalfOf` address
   * @param asset The address of the borrowed underlying asset previously borrowed
   * @param amount The amount to repay
   * - Send the value type(uint256).max in order to repay the whole debt for `asset` on the specific `debtMode`
   * @param rateMode The interest rate mode at of the debt the user wants to repay: 1 for Stable, 2 for Variable
   * @param onBehalfOf Address of the user who will get his debt reduced/removed. Should be the address of the
   * user calling the function if he wants to reduce/remove his own debt, or the address of any other
   * other borrower whose debt should be removed
   * @return The final amount repaid
   **/
  function repay(
    address asset,
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external returns (uint256);

  /**
   * @dev Allows a borrower to swap his debt between stable and variable mode, or viceversa
   * @param asset The address of the underlying asset borrowed
   * @param rateMode The rate mode that the user wants to swap to
   **/
  function swapBorrowRateMode(address asset, uint256 rateMode) external;

  /**
   * @dev Rebalances the stable interest rate of a user to the current stable rate defined on the reserve.
   * - Users can be rebalanced if the following conditions are satisfied:
   *     1. Usage ratio is above 95%
   *     2. the current deposit APY is below REBALANCE_UP_THRESHOLD * maxVariableBorrowRate, which means that too much has been
   *        borrowed at a stable rate and depositors are not earning enough
   * @param asset The address of the underlying asset borrowed
   * @param user The address of the user to be rebalanced
   **/
  function rebalanceStableBorrowRate(address asset, address user) external;

  /**
   * @dev Allows depositors to enable/disable a specific deposited asset as collateral
   * @param asset The address of the underlying asset deposited
   * @param useAsCollateral `true` if the user wants to use the deposit as collateral, `false` otherwise
   **/
  function setUserUseReserveAsCollateral(address asset, bool useAsCollateral) external;

  /**
   * @dev Function to liquidate a non-healthy position collateral-wise, with Health Factor below 1
   * - The caller (liquidator) covers `debtToCover` amount of debt of the user getting liquidated, and receives
   *   a proportionally amount of the `collateralAsset` plus a bonus to cover market risk
   * @param collateralAsset The address of the underlying asset used as collateral, to receive as result of the liquidation
   * @param debtAsset The address of the underlying borrowed asset to be repaid with the liquidation
   * @param user The address of the borrower getting liquidated
   * @param debtToCover The debt amount of borrowed `asset` the liquidator wants to cover
   * @param receiveAToken `true` if the liquidators wants to receive the collateral aTokens, `false` if he wants
   * to receive the underlying collateral asset directly
   **/
  function liquidationCall(
    address collateralAsset,
    address debtAsset,
    address user,
    uint256 debtToCover,
    bool receiveAToken
  ) external;

  /**
   * @dev Allows smartcontracts to access the liquidity of the pool within one transaction,
   * as long as the amount taken plus a fee is returned.
   * IMPORTANT There are security concerns for developers of flashloan receiver contracts that must be kept into consideration.
   * For further details please visit https://developers.aave.com
   * @param receiverAddress The address of the contract receiving the funds, implementing the IFlashLoanReceiver interface
   * @param assets The addresses of the assets being flash-borrowed
   * @param amounts The amounts amounts being flash-borrowed
   * @param modes Types of the debt to open if the flash loan is not returned:
   *   0 -> Don't open any debt, just revert if funds can't be transferred from the receiver
   *   1 -> Open debt at stable rate for the value of the amount flash-borrowed to the `onBehalfOf` address
   *   2 -> Open debt at variable rate for the value of the amount flash-borrowed to the `onBehalfOf` address
   * @param onBehalfOf The address  that will receive the debt in the case of using on `modes` 1 or 2
   * @param params Variadic packed params to pass to the receiver as extra information
   * @param referralCode Code used to register the integrator originating the operation, for potential rewards.
   *   0 if the action is executed directly by the user, without any middle-man
   **/
  function flashLoan(
    address receiverAddress,
    address[] calldata assets,
    uint256[] calldata amounts,
    uint256[] calldata modes,
    address onBehalfOf,
    bytes calldata params,
    uint16 referralCode
  ) external;

  /**
   * @dev Returns the user account data across all the reserves
   * @param user The address of the user
   * @return totalCollateralETH the total collateral in ETH of the user
   * @return totalDebtETH the total debt in ETH of the user
   * @return availableBorrowsETH the borrowing power left of the user
   * @return currentLiquidationThreshold the liquidation threshold of the user
   * @return ltv the loan to value of the user
   * @return healthFactor the current health factor of the user
   **/
  function getUserAccountData(address user)
    external
    view
    returns (
      uint256 totalCollateralETH,
      uint256 totalDebtETH,
      uint256 availableBorrowsETH,
      uint256 currentLiquidationThreshold,
      uint256 ltv,
      uint256 healthFactor
    );

  function initReserve(
    address reserve,
    address aTokenAddress,
    address stableDebtAddress,
    address variableDebtAddress,
    address interestRateStrategyAddress
  ) external;

  function setReserveInterestRateStrategyAddress(address reserve, address rateStrategyAddress)
    external;

  function setConfiguration(address reserve, uint256 configuration) external;

  /**
   * @dev Returns the configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The configuration of the reserve
   **/
  function getConfiguration(address asset)
    external
    view
    returns (DataTypes.ReserveConfigurationMap memory);

  /**
   * @dev Returns the configuration of the user across all the reserves
   * @param user The user address
   * @return The configuration of the user
   **/
  function getUserConfiguration(address user)
    external
    view
    returns (DataTypes.UserConfigurationMap memory);

  /**
   * @dev Returns the normalized income normalized income of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve's normalized income
   */
  function getReserveNormalizedIncome(address asset) external view returns (uint256);

  /**
   * @dev Returns the normalized variable debt per unit of asset
   * @param asset The address of the underlying asset of the reserve
   * @return The reserve normalized variable debt
   */
  function getReserveNormalizedVariableDebt(address asset) external view returns (uint256);

  /**
   * @dev Returns the state and configuration of the reserve
   * @param asset The address of the underlying asset of the reserve
   * @return The state of the reserve
   **/
  function getReserveData(address asset) external view returns (DataTypes.ReserveData memory);

  function finalizeTransfer(
    address asset,
    address from,
    address to,
    uint256 amount,
    uint256 balanceFromAfter,
    uint256 balanceToBefore
  ) external;

  function getReservesList() external view returns (address[] memory);

  function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);

  function setPause(bool val) external;

  function paused() external view returns (bool);
}

// File: @aave/protocol-v2/contracts/interfaces/IPriceOracle.sol
/************
@title IPriceOracle interface
@notice Interface for the Aave price oracle.*/
interface IPriceOracle {
  /***********
    @dev returns the asset price in ETH
     */
  function getAssetPrice(address asset) external view returns (uint256);

  /***********
    @dev sets the asset price, in wei
     */
  function setAssetPrice(address asset, uint256 price) external;
}



// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: interfaces/IQuickSwapRouter.sol
interface IQuickSwapRouter is IUniswapV2Router02 {}

// File: @aave/protocol-v2/contracts/interfaces/IAaveIncentivesController.sol
interface IAaveIncentivesController {
  function handleAction(
    address user,
    uint256 userBalance,
    uint256 totalSupply
  ) external;
}

// File: interfaces/IAaveIncentivesControllerExtended.sol
interface IAaveIncentivesControllerExtended is IAaveIncentivesController {
    /**
     * @dev Returns the total of rewards of an user, already accrued + not yet accrued
     * @param user The address of the user
     * @return The rewards
     **/
    function getRewardsBalance(address[] calldata assets, address user)
        external
        view
        returns (uint256);

    /**
     * @dev Claims reward for an user, on all the assets of the lending pool, accumulating the pending rewards
     * @param amount Amount of rewards to claim
     * @param to Address that will be receiving the rewards
     * @return Rewards claimed
     **/
    function claimRewards(
        address[] calldata assets,
        uint256 amount,
        address to
    ) external returns (uint256);
}

import {SafeERC20, SafeMath, IERC20, Address} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BaseStrategyInitializable, BaseStrategy} from "../BaseStrategy.sol";
import {DataTypes} from "../libraries/aave/DataTypes.sol";

// File: contracts/StrategyLeveragedAAVE.sol
contract StrategyLeveragedAAVE is BaseStrategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    ILendingPoolAddressesProvider public constant ADDRESS_PROVIDER = ILendingPoolAddressesProvider(0xd05e3E715d945B59290df0ae8eF85c1BdB684744);

    IERC20 public immutable aToken;
    IERC20 public immutable vToken;
    ILendingPool public immutable LENDING_POOL;

    uint256 public immutable DECIMALS; // For toMATIC conversion

    // Hardhcoded from the Liquidity Mining docs: https://docs.aave.com/developers/guides/liquidity-mining
    IAaveIncentivesControllerExtended public constant INCENTIVES_CONTROLLER =
    IAaveIncentivesControllerExtended(0x357D51124f59836DeD84c8a1730D72B749d8BC23);

    // For Swapping
    IQuickSwapRouter public constant ROUTER = IQuickSwapRouter(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);

    IERC20 public constant WMATIC_TOKEN = IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);

    uint256 public minWMATICToWantPrice = 8000; // 80% // Seems like Oracle is slightly off

    // Should we harvest before prepareMigration
    bool public harvestBeforeMigrate = true;

    // Should we ensure the swap will be within slippage params before performing it during normal harvest?
    bool public checkSlippageOnHarvest = false;

    // Leverage
    uint256 public constant MAX_BPS = 10000;
    // uint256 public minHealth = 1080000000000000000; // 1.08 with 18 decimals this is slighly above 70% tvl
    uint256 public minHealth = 1310000000000000000; // 1.31 with 18 decimals this is slighly above 50% loan to value, max for matic

    uint256 public minRebalanceAmount = 0; // should be changed based on decimals of the want token

    constructor(address _vault) public BaseStrategy(_vault) {
        // You can set these parameters on deployment to whatever you want
        maxReportDelay = 6300;
        profitFactor = 100;
        debtThreshold = 0;

        // Get lending Pool
        ILendingPool lendingPool = ILendingPool(ADDRESS_PROVIDER.getLendingPool());

        // Set lending pool as immutable
        LENDING_POOL = lendingPool;

        // Get Tokens Addresses
        DataTypes.ReserveData memory data = lendingPool.getReserveData(address(want));

        // Get aToken - aToken is AAVE Market Token address of the want token
        aToken = IERC20(data.aTokenAddress);

        // Get vToken - vToken is AAVE Market variable debt address of the want token
        vToken = IERC20(data.variableDebtTokenAddress);

        // Get Decimals
        DECIMALS = ERC20(address(want)).decimals();

        want.safeApprove(address(lendingPool), type(uint256).max);
        WMATIC_TOKEN.safeApprove(address(ROUTER), type(uint256).max);
    }

    function setMinHealth(uint256 newMinHealth) external onlyKeepers {
        require(newMinHealth >= 1000000000000000000, "Need higher health");
        minHealth = newMinHealth;
    }

    function setMinRebalanceAmount(uint256 newMinRebalanceAmount) external onlyKeepers {
        minRebalanceAmount = newMinRebalanceAmount;
    }

    function setHarvestBeforeMigrate(bool newHarvestBeforeMigrate) external onlyKeepers {
        harvestBeforeMigrate = newHarvestBeforeMigrate;
    }

    function setCheckSlippageOnHarvest(bool newCheckSlippageOnHarvest) external onlyKeepers {
        checkSlippageOnHarvest = newCheckSlippageOnHarvest;
    }

    function setMinPrice(uint256 newMinWMATICToWantPrice) external onlyKeepers {
        require(newMinWMATICToWantPrice >= 0 && newMinWMATICToWantPrice <= MAX_BPS);
        minWMATICToWantPrice = newMinWMATICToWantPrice;
    }

    // ******** OVERRIDE THESE METHODS FROM BASE CONTRACT ************

    function name() external view override returns (string memory) {
        return string(abi.encodePacked("Strategy-Leveraged-AAVE-", ERC20(address(want)).symbol()));
    }

    function estimatedTotalAssets() public view override returns (uint256) {
        // Balance of want + balance in AAVE
        uint256 liquidBalance = want.balanceOf(address(this)).add(deposited()).sub(borrowed());

        // Return balance + reward
        return liquidBalance.add(valueOfRewards());
    }

    function prepareReturn(uint256 _debtOutstanding)
    internal
    override
    returns (
        uint256 _profit,
        uint256 _loss,
        uint256 _debtPayment
    )
    {
        // NOTE: This means that if we are paying back we just deleverage
        // While if we are not paying back, we are harvesting rewards
        if (_debtOutstanding > 0) {
            // Withdraw and Repay
            uint256 toWithdraw = _debtOutstanding;

            // Get it all out
            _divestFromAAVE();

            // Get rewards
            _claimRewardsAndGetMoreWant();

            // Repay debt
            uint256 maxRepay = want.balanceOf(address(this));
            if (_debtOutstanding > maxRepay) {
                // we can't pay all, means we lost some
                _loss = _debtOutstanding.sub(maxRepay);
                _debtPayment = maxRepay;
            } else {
                // We can pay all, let's do it
                _debtPayment = toWithdraw;
            }
        } else {
            // Do normal Harvest
            _debtPayment = 0;

            // Get current amount of want // used to estimate profit
            uint256 beforeBalance = want.balanceOf(address(this));

            // Claim WMATIC -> swap into want
            _claimRewardsAndGetMoreWant();

            (uint256 earned, uint256 lost) = _repayAAVEBorrow(beforeBalance);

            _profit = earned;
            _loss = lost;
        }
    }

    function _repayAAVEBorrow(uint256 beforeBalance) internal returns (uint256 _profit, uint256 _loss) {
        // Calculate Gain from AAVE interest // NOTE: This should never happen as we take more debt than we earn
        uint256 currentWantInAave = deposited().sub(borrowed());
        uint256 initialDeposit = vault.strategies(address(this)).totalDebt;
        if (currentWantInAave > initialDeposit) {
            uint256 interestProfit = currentWantInAave.sub(initialDeposit);
            LENDING_POOL.withdraw(address(want), interestProfit, address(this));
            // Withdraw interest of aToken so that now we have exactly the same amount
        }

        uint256 afterBalance = want.balanceOf(address(this));
        uint256 wantEarned = afterBalance.sub(beforeBalance); // Earned before repaying debt

        // Pay off any debt
        // Debt is equal to negative of canBorrow
        uint256 toRepay = debtBelowHealth();
        if (toRepay > wantEarned) {
            // We lost some money

            // Repay all we can, rest is loss
            LENDING_POOL.repay(address(want), wantEarned, 2, address(this));

            _loss = toRepay.sub(wantEarned);

            // Notice that once the strats starts loosing funds here, you should probably retire it as it's not profitable
        } else {
            // We made money or are even

            // Let's repay the debtBelowHealth
            uint256 repaid = toRepay;

            _profit = wantEarned.sub(repaid);

            if (repaid > 0) {
                LENDING_POOL.repay(address(want), repaid, 2, address(this));
            }
        }
    }

    function adjustPosition(uint256 _debtOutstanding) internal override {
        // TODO: Do something to invest excess `want` tokens (from the Vault) into your positions
        // NOTE: Try to adjust positions so that `_debtOutstanding` can be freed up on *next* harvest (not immediately)
        uint256 wantAvailable = want.balanceOf(address(this));
        if (wantAvailable > _debtOutstanding) {
            uint256 toDeposit = wantAvailable.sub(_debtOutstanding);
            LENDING_POOL.deposit(address(want), toDeposit, address(this), 0);

            // Lever up
            _invest();
        }
    }

    function balanceOfRewards() public view returns (uint256) {
        // Get rewards
        address[] memory assets = new address[](2);
        assets[0] = address(aToken);
        assets[1] = address(vToken);

        uint256 totalRewards = INCENTIVES_CONTROLLER.getRewardsBalance(assets, address(this));
        return totalRewards;
    }

    function valueOfRewards() public view returns (uint256) {
        return maticToWant(balanceOfRewards());
    }

    // Get WMATIC
    function _claimRewards() internal {
        // Get rewards
        address[] memory assets = new address[](2);
        assets[0] = address(aToken);
        assets[1] = address(vToken);

        // Get Rewards, withdraw all
        INCENTIVES_CONTROLLER.claimRewards(assets, type(uint256).max, address(this));
    }

    function _fromMATICToWant(uint256 amountIn, uint256 minOut) internal {
        address[] memory path = new address[](2);
        path[0] = address(WMATIC_TOKEN);
        path[1] = address(want);
        if (WMATIC_TOKEN != want) {
            ROUTER.swapExactTokensForTokens(amountIn, minOut, path, address(this), now);
        }
    }

    function _claimRewardsAndGetMoreWant() internal {
        _claimRewards();

        uint256 rewardsAmount = WMATIC_TOKEN.balanceOf(address(this));

        if (rewardsAmount == 0) {
            return;
        }

        uint256 maticToSwap = WMATIC_TOKEN.balanceOf(address(this));

        uint256 minWantOut = 0;
        if (checkSlippageOnHarvest) {
            minWantOut = maticToWant(maticToSwap).mul(minWMATICToWantPrice).div(MAX_BPS);
        }

        _fromMATICToWant(maticToSwap, minWantOut);
    }

    function liquidatePosition(uint256 _amountNeeded) internal override returns (uint256 _liquidatedAmount, uint256 _loss) {
        // TODO: Do stuff here to free up to `_amountNeeded` from all positions back into `want`
        // NOTE: Maintain invariant `want.balanceOf(this) >= _liquidatedAmount`
        // NOTE: Maintain invariant `_liquidatedAmount + _loss <= _amountNeeded`

        // Lever Down
        _divestFromAAVE();

        uint256 totalAssets = want.balanceOf(address(this));
        if (_amountNeeded > totalAssets) {
            _liquidatedAmount = totalAssets;
            _loss = _amountNeeded.sub(totalAssets);
        } else {
            _liquidatedAmount = _amountNeeded;
        }
    }

    // Withdraw all from AAVE Pool
    function liquidateAllPositions() internal override returns (uint256) {
        // Repay all debt and divest
        _divestFromAAVE();

        // Get rewards before leaving
        _claimRewardsAndGetMoreWant();

        // Return amount freed
        return want.balanceOf(address(this));
    }

    // NOTE: Can override `tendTrigger` and `harvestTrigger` if necessary

    function prepareMigration(address _newStrategy) internal override {
        // TODO: Transfer any non-`want` tokens to the new strategy
        // NOTE: `migrate` will automatically forward all `want` in this strategy to the new one
        // This is gone if we use upgradeable

        //Divest all
        _divestFromAAVE();

        if (harvestBeforeMigrate) {
            // Harvest rewards one last time
            _claimRewardsAndGetMoreWant();
        }

        // Just in case we don't fully liquidate to want
        if (aToken.balanceOf(address(this)) > 0) {
            aToken.safeTransfer(_newStrategy, aToken.balanceOf(address(this)));
        }

        if (WMATIC_TOKEN.balanceOf(address(this)) > 0) {
            WMATIC_TOKEN.safeTransfer(_newStrategy, WMATIC_TOKEN.balanceOf(address(this)));
        }
    }

    // Override this to add all tokens/tokenized positions this contract manages
    // on a *persistent* basis (e.g. not just for swapping back to want ephemerally)
    // NOTE: Do *not* include `want`, already included in `sweep` below
    //
    // Example:
    //
    //    function protectedTokens() internal override view returns (address[] memory) {
    //      address[] memory protected = new address[](3);
    //      protected[0] = tokenA;
    //      protected[1] = tokenB;
    //      protected[2] = tokenC;
    //      return protected;
    //    }
    function protectedTokens() internal view override returns (address[] memory) {
        address[] memory protected = new address[](2);
        protected[0] = address(aToken);
        protected[1] = address(WMATIC_TOKEN);
        return protected;
    }

    /**
     * @notice
     *  Provide an accurate conversion from `_amtInWei` (denominated in wei)
     *  to `want` (using the native decimal characteristics of `want`).
     * @dev
     *  Care must be taken when working with decimals to assure that the conversion
     *  is compatible. As an example:
     *
     *      given 1e17 wei (0.1 MATIC) as input, and want is USDC (6 decimals),
     *      with USDC/MATIC = 1800, this should give back 1800000000 (180 USDC)
     *
     * @param _amtInWei The amount (in wei/1e-18 ETH) to convert to `want`
     * @return The amount in `want` of `_amtInEth` converted to `want`
     **/
    function maticToWant(uint256 _amtInWei) public view virtual override returns (uint256) {
        address priceOracle = ADDRESS_PROVIDER.getPriceOracle();
        uint256 priceInMATIC = IPriceOracle(priceOracle).getAssetPrice(address(want));

        // Opposite of priceInMATIC
        // Multiply first to keep rounding
        uint256 priceInWant = _amtInWei.mul(10**DECIMALS).div(priceInMATIC);

        return priceInWant;
    }

    /* Leverage functions */
    function deposited() public view returns (uint256) {
        return aToken.balanceOf(address(this));
    }

    function borrowed() public view returns (uint256) {
        return vToken.balanceOf(address(this));
    }

    // What should we repay?
    function debtBelowHealth() public view returns (uint256) {
        (
        ,
        ,
        ,
        ,
        /*uint256 totalCollateralETH*/
        /*uint256 totalDebtETH*/
        /*uint256 availableBorrowsETH*/
        /*uint256 currentLiquidationThreshold*/
        uint256 ltv,
        uint256 healthFactor
        ) = LENDING_POOL.getUserAccountData(address(this));

        // How much did we go off of minHealth? //NOTE: We always borrow as much as we can
        uint256 maxBorrow = deposited().mul(ltv).div(MAX_BPS);

        if (healthFactor < minHealth && borrowed() > maxBorrow) {
            uint256 maxValue = borrowed().sub(maxBorrow);

            return maxValue;
        }

        return 0;
    }

    // NOTE: We always borrow max, no fucks given
    function canBorrow() public view returns (uint256) {
        (
        ,
        ,
        ,
        ,
        /*uint256 totalCollateralETH*/
        /*uint256 totalDebtETH*/
        /*uint256 availableBorrowsETH*/
        /*uint256 currentLiquidationThreshold*/
        uint256 ltv,
        uint256 healthFactor
        ) = LENDING_POOL.getUserAccountData(address(this));

        if (healthFactor > minHealth) {
            // Amount = deposited * ltv - borrowed
            // Div MAX_BPS because because ltv / maxbps is the percent
            uint256 maxValue = deposited().mul(ltv).div(MAX_BPS).sub(borrowed());

            // Don't borrow if it's dust, save gas
            if (maxValue < minRebalanceAmount) {
                return 0;
            }

            return maxValue;
        }

        return 0;
    }

    function _invest() internal {
        // Loop on it until it's properly done
        uint256 max_iterations = 5;
        for (uint256 i = 0; i < max_iterations; i++) {
            uint256 toBorrow = canBorrow();
            if (toBorrow > 0) {
                LENDING_POOL.borrow(address(want), toBorrow, 2, 0, address(this));

                LENDING_POOL.deposit(address(want), toBorrow, address(this), 0);
            } else {
                break;
            }
        }
    }

    // Divest all from AAVE, awful gas, but hey, it works
    function _divestFromAAVE() internal {
        uint256 repayAmount = canRepay(); // The "unsafe" (below target health) you can withdraw

        // Loop to withdraw until you have the amount you need
        while (repayAmount != uint256(-1)) {
            _withdrawStepFromAAVE(repayAmount);
            repayAmount = canRepay();
        }
        if (deposited() > 0) {
            // Withdraw the rest here
            LENDING_POOL.withdraw(address(want), type(uint256).max, address(this));
        }
    }

    // Withdraw and Repay AAVE Debt
    function _withdrawStepFromAAVE(uint256 canRepay) internal {
        if (canRepay > 0) {
            //Repay this step
            LENDING_POOL.withdraw(address(want), canRepay, address(this));
            LENDING_POOL.repay(address(want), canRepay, 2, address(this));
        }
    }

    // returns 95% of the collateral we can withdraw from aave, used to loop and repay debts
    function canRepay() public view returns (uint256) {
        (
        ,
        ,
        ,
        /*uint256 totalCollateralETH*/
        /*uint256 totalDebtETH*/
        /*uint256 availableBorrowsETH*/
        uint256 currentLiquidationThreshold,
        ,

        ) =
        /*uint256 ltv*/
        /*uint256 healthFactor*/
        LENDING_POOL.getUserAccountData(address(this));

        uint256 aBalance = deposited();
        uint256 vBalance = borrowed();

        if (vBalance == 0) {
            return uint256(-1); //You have repaid all
        }

        uint256 diff = aBalance.sub(vBalance.mul(10000).div(currentLiquidationThreshold));
        uint256 inWant = diff.mul(95).div(100); // Take 95% just to be safe

        return inWant;
    }

    /** Manual Functions */

    /** Leverage Manual Functions */
    // Emergency function to immediately deleverage to 0
    function manualDivestFromAAVE() public onlyVaultManagers {
        _divestFromAAVE();
    }

    // Manually perform 5 loops to lever up
    // Safe because it's capped by canBorrow
    function manualLeverUp() public onlyVaultManagers {
        _invest();
    }

    // Emergency function that we can use to deleverage manually if something is broken
    // If something goes wrong, just try smaller and smaller can repay amounts
    function manualWithdrawStepFromAAVE(uint256 toRepay) public onlyVaultManagers {
        _withdrawStepFromAAVE(toRepay);
    }

    // Take some funds from manager and use them to repay
    // Useful if you ever go below 1 HF and somehow you didn't get liquidated
    function manualRepayFromManager(uint256 toRepay) public onlyVaultManagers {
        want.safeTransferFrom(msg.sender, address(this), toRepay);
        LENDING_POOL.repay(address(want), toRepay, 2, address(this));
    }

    /** DCA Manual Functions */

    // Get the rewards
    function manualClaimRewards() public onlyVaultManagers {
        _claimRewards();
    }

    // Swap from AAVE to Want
    ///@param amountToSwap Amount of AAVE to Swap, NOTE: You have to calculate the amount!!
    ///@param multiplierInWei pricePerToken including slippage, will be divided by 10 ** 18
    function manualSwapFromMATICToWant(uint256 amountToSwap, uint256 multiplierInWei) public onlyVaultManagers {
        uint256 amountOutMinimum = amountToSwap.mul(multiplierInWei).div(10**18);

        _fromMATICToWant(amountToSwap, amountOutMinimum);
    }
}