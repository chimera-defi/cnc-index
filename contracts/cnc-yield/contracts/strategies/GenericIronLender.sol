// /**
//  *Submitted for verification at FtmScan.com on 2021-10-05
// */

// // SPDX-License-Identifier: GPL-3.0

// pragma solidity 0.6.12;
// pragma experimental ABIEncoderV2;

// // Global Enums and Structs



// struct StrategyParams {
//     uint256 performanceFee;
//     uint256 activation;
//     uint256 debtRatio;
//     uint256 minDebtPerHarvest;
//     uint256 maxDebtPerHarvest;
//     uint256 lastReport;
//     uint256 totalDebt;
//     uint256 totalGain;
//     uint256 totalLoss;
// }

// // Part: IBaseStrategy

// interface IBaseStrategy {
//     function apiVersion() external pure returns (string memory);

//     function name() external pure returns (string memory);

//     function vault() external view returns (address);

//     function keeper() external view returns (address);

//     function tendTrigger(uint256 callCost) external view returns (bool);

//     function tend() external;

//     function harvestTrigger(uint256 callCost) external view returns (bool);

//     function harvest() external;

//     function management() external view returns (address);
// }

// // Part: IGenericLender

// interface IGenericLender {
//     function lenderName() external view returns (string memory);

//     function nav() external view returns (uint256);

//     function strategy() external view returns (address);

//     function apr() external view returns (uint256);

//     function weightedApr() external view returns (uint256);

//     function withdraw(uint256 amount) external returns (uint256);

//     function emergencyWithdraw(uint256 amount) external;

//     function deposit() external;

//     function withdrawAll() external returns (bool);

//     function hasAssets() external view returns (bool);

//     function aprAfterDeposit(uint256 amount) external view returns (uint256);

//     function setDust(uint256 _dust) external;

//     function sweep(address _token) external;
// }

// // Part: IUniswapV2Router01

// interface IUniswapV2Router01 {
//     function factory() external pure returns (address);

//     function WETH() external pure returns (address);

//     function addLiquidity(
//         address tokenA,
//         address tokenB,
//         uint256 amountADesired,
//         uint256 amountBDesired,
//         uint256 amountAMin,
//         uint256 amountBMin,
//         address to,
//         uint256 deadline
//     )
//         external
//         returns (
//             uint256 amountA,
//             uint256 amountB,
//             uint256 liquidity
//         );

//     function addLiquidityETH(
//         address token,
//         uint256 amountTokenDesired,
//         uint256 amountTokenMin,
//         uint256 amountETHMin,
//         address to,
//         uint256 deadline
//     )
//         external
//         payable
//         returns (
//             uint256 amountToken,
//             uint256 amountETH,
//             uint256 liquidity
//         );

//     function removeLiquidity(
//         address tokenA,
//         address tokenB,
//         uint256 liquidity,
//         uint256 amountAMin,
//         uint256 amountBMin,
//         address to,
//         uint256 deadline
//     ) external returns (uint256 amountA, uint256 amountB);

//     function removeLiquidityETH(
//         address token,
//         uint256 liquidity,
//         uint256 amountTokenMin,
//         uint256 amountETHMin,
//         address to,
//         uint256 deadline
//     ) external returns (uint256 amountToken, uint256 amountETH);

//     function removeLiquidityWithPermit(
//         address tokenA,
//         address tokenB,
//         uint256 liquidity,
//         uint256 amountAMin,
//         uint256 amountBMin,
//         address to,
//         uint256 deadline,
//         bool approveMax,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) external returns (uint256 amountA, uint256 amountB);

//     function removeLiquidityETHWithPermit(
//         address token,
//         uint256 liquidity,
//         uint256 amountTokenMin,
//         uint256 amountETHMin,
//         address to,
//         uint256 deadline,
//         bool approveMax,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) external returns (uint256 amountToken, uint256 amountETH);

//     function swapExactTokensForTokens(
//         uint256 amountIn,
//         uint256 amountOutMin,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external returns (uint256[] memory amounts);

//     function swapTokensForExactTokens(
//         uint256 amountOut,
//         uint256 amountInMax,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external returns (uint256[] memory amounts);

//     function swapExactETHForTokens(
//         uint256 amountOutMin,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external payable returns (uint256[] memory amounts);

//     function swapTokensForExactETH(
//         uint256 amountOut,
//         uint256 amountInMax,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external returns (uint256[] memory amounts);

//     function swapExactTokensForETH(
//         uint256 amountIn,
//         uint256 amountOutMin,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external returns (uint256[] memory amounts);

//     function swapETHForExactTokens(
//         uint256 amountOut,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external payable returns (uint256[] memory amounts);

//     function quote(
//         uint256 amountA,
//         uint256 reserveA,
//         uint256 reserveB
//     ) external pure returns (uint256 amountB);

//     function getAmountOut(
//         uint256 amountIn,
//         uint256 reserveIn,
//         uint256 reserveOut
//     ) external pure returns (uint256 amountOut);

//     function getAmountIn(
//         uint256 amountOut,
//         uint256 reserveIn,
//         uint256 reserveOut
//     ) external pure returns (uint256 amountIn);

//     function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

//     function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
// }

// // Part: InterestRateModel

// interface InterestRateModel {
//     /**
//      * @notice Calculates the current borrow interest rate per block
//      * @param cash The total amount of cash the market has
//      * @param borrows The total amount of borrows the market has outstanding
//      * @param reserves The total amount of reserves the market has
//      * @return The borrow rate per block (as a percentage, and scaled by 1e18)
//      */
//     function getBorrowRate(
//         uint256 cash,
//         uint256 borrows,
//         uint256 reserves
//     ) external view returns (uint256, uint256);

//     /**
//      * @notice Calculates the current supply interest rate per block
//      * @param cash The total amount of cash the market has
//      * @param borrows The total amount of borrows the market has outstanding
//      * @param reserves The total amount of reserves the market has
//      * @param reserveFactorMantissa The current reserve factor the market has
//      * @return The supply rate per block (as a percentage, and scaled by 1e18)
//      */
//     function getSupplyRate(
//         uint256 cash,
//         uint256 borrows,
//         uint256 reserves,
//         uint256 reserveFactorMantissa
//     ) external view returns (uint256);
// }


// // Part: CTokenI

// interface CTokenI {
//     /*** Market Events ***/

//     /**
//      * @notice Event emitted when interest is accrued
//      */
//     event AccrueInterest(uint256 cashPrior, uint256 interestAccumulated, uint256 borrowIndex, uint256 totalBorrows);

//     /**
//      * @notice Event emitted when tokens are minted
//      */
//     event Mint(address minter, uint256 mintAmount, uint256 mintTokens);

//     /**
//      * @notice Event emitted when tokens are redeemed
//      */
//     event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

//     /**
//      * @notice Event emitted when underlying is borrowed
//      */
//     event Borrow(address borrower, uint256 borrowAmount, uint256 accountBorrows, uint256 totalBorrows);

//     /**
//      * @notice Event emitted when a borrow is repaid
//      */
//     event RepayBorrow(address payer, address borrower, uint256 repayAmount, uint256 accountBorrows, uint256 totalBorrows);

//     /**
//      * @notice Event emitted when a borrow is liquidated
//      */
//     event LiquidateBorrow(address liquidator, address borrower, uint256 repayAmount, address cTokenCollateral, uint256 seizeTokens);

//     /*** Admin Events ***/

//     /**
//      * @notice Event emitted when pendingAdmin is changed
//      */
//     event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

//     /**
//      * @notice Event emitted when pendingAdmin is accepted, which means admin is updated
//      */
//     event NewAdmin(address oldAdmin, address newAdmin);

//     /**
//      * @notice Event emitted when the reserve factor is changed
//      */
//     event NewReserveFactor(uint256 oldReserveFactorMantissa, uint256 newReserveFactorMantissa);

//     /**
//      * @notice Event emitted when the reserves are added
//      */
//     event ReservesAdded(address benefactor, uint256 addAmount, uint256 newTotalReserves);

//     /**
//      * @notice Event emitted when the reserves are reduced
//      */
//     event ReservesReduced(address admin, uint256 reduceAmount, uint256 newTotalReserves);

//     /**
//      * @notice EIP20 Transfer event
//      */
//     event Transfer(address indexed from, address indexed to, uint256 amount);

//     /**
//      * @notice EIP20 Approval event
//      */
//     event Approval(address indexed owner, address indexed spender, uint256 amount);

//     /**
//      * @notice Failure event
//      */
//     event Failure(uint256 error, uint256 info, uint256 detail);

//     function transfer(address dst, uint256 amount) external returns (bool);

//     function transferFrom(
//         address src,
//         address dst,
//         uint256 amount
//     ) external returns (bool);

//     function approve(address spender, uint256 amount) external returns (bool);

//     function allowance(address owner, address spender) external view returns (uint256);

//     function balanceOf(address owner) external view returns (uint256);

//     function balanceOfUnderlying(address owner) external returns (uint256);

//     function getAccountSnapshot(address account)
//         external
//         view
//         returns (
//             uint256,
//             uint256,
//             uint256,
//             uint256
//         );

//     function borrowRatePerBlock() external view returns (uint256);

//     function supplyRatePerBlock() external view returns (uint256);

//     function totalBorrowsCurrent() external returns (uint256);

//     function borrowBalanceCurrent(address account) external returns (uint256);

//     function borrowBalanceStored(address account) external view returns (uint256);

//     function exchangeRateCurrent() external returns (uint256);

//     function accrualBlockNumber() external view returns (uint256);

//     function exchangeRateStored() external view returns (uint256);

//     function getCash() external view returns (uint256);

//     function accrueInterest() external returns (uint256);

//     function interestRateModel() external view returns (InterestRateModel);

//     function totalReserves() external view returns (uint256);

//     function reserveFactorMantissa() external view returns (uint256);

//     function seize(
//         address liquidator,
//         address borrower,
//         uint256 seizeTokens
//     ) external returns (uint256);

//     function totalBorrows() external view returns (uint256);

//     function totalSupply() external view returns (uint256);
// }

// // Part: IUniswapV2Router02

// interface IUniswapV2Router02 is IUniswapV2Router01 {
//     function removeLiquidityETHSupportingFeeOnTransferTokens(
//         address token,
//         uint256 liquidity,
//         uint256 amountTokenMin,
//         uint256 amountETHMin,
//         address to,
//         uint256 deadline
//     ) external returns (uint256 amountETH);

//     function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
//         address token,
//         uint256 liquidity,
//         uint256 amountTokenMin,
//         uint256 amountETHMin,
//         address to,
//         uint256 deadline,
//         bool approveMax,
//         uint8 v,
//         bytes32 r,
//         bytes32 s
//     ) external returns (uint256 amountETH);

//     function swapExactTokensForTokensSupportingFeeOnTransferTokens(
//         uint256 amountIn,
//         uint256 amountOutMin,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external;

//     function swapExactETHForTokensSupportingFeeOnTransferTokens(
//         uint256 amountOutMin,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external payable;

//     function swapExactTokensForETHSupportingFeeOnTransferTokens(
//         uint256 amountIn,
//         uint256 amountOutMin,
//         address[] calldata path,
//         address to,
//         uint256 deadline
//     ) external;
// }

// // Part: OpenZeppelin/openzeppelin-contracts@3.1.0/SafeERC20

// // Part: iearn-finance/yearn-vaults@0.4.3/VaultAPI

// interface VaultAPI is IERC20 {
//     function name() external view returns (string calldata);

//     function symbol() external view returns (string calldata);

//     function decimals() external view returns (uint256);

//     function apiVersion() external pure returns (string memory);

//     function permit(
//         address owner,
//         address spender,
//         uint256 amount,
//         uint256 expiry,
//         bytes calldata signature
//     ) external returns (bool);

//     // NOTE: Vyper produces multiple signatures for a given function with "default" args
//     function deposit() external returns (uint256);

//     function deposit(uint256 amount) external returns (uint256);

//     function deposit(uint256 amount, address recipient) external returns (uint256);

//     // NOTE: Vyper produces multiple signatures for a given function with "default" args
//     function withdraw() external returns (uint256);

//     function withdraw(uint256 maxShares) external returns (uint256);

//     function withdraw(uint256 maxShares, address recipient) external returns (uint256);

//     function token() external view returns (address);

//     function strategies(address _strategy) external view returns (StrategyParams memory);

//     function pricePerShare() external view returns (uint256);

//     function totalAssets() external view returns (uint256);

//     function depositLimit() external view returns (uint256);

//     function maxAvailableShares() external view returns (uint256);

//     /**
//      * View how much the Vault would increase this Strategy's borrow limit,
//      * based on its present performance (since its last report). Can be used to
//      * determine expectedReturn in your Strategy.
//      */
//     function creditAvailable() external view returns (uint256);

//     /**
//      * View how much the Vault would like to pull back from the Strategy,
//      * based on its present performance (since its last report). Can be used to
//      * determine expectedReturn in your Strategy.
//      */
//     function debtOutstanding() external view returns (uint256);

//     /**
//      * View how much the Vault expect this Strategy to return at the current
//      * block, based on its present performance (since its last report). Can be
//      * used to determine expectedReturn in your Strategy.
//      */
//     function expectedReturn() external view returns (uint256);

//     /**
//      * This is the main contact point where the Strategy interacts with the
//      * Vault. It is critical that this call is handled as intended by the
//      * Strategy. Therefore, this function will be called by BaseStrategy to
//      * make sure the integration is correct.
//      */
//     function report(
//         uint256 _gain,
//         uint256 _loss,
//         uint256 _debtPayment
//     ) external returns (uint256);

//     /**
//      * This function should only be used in the scenario where the Strategy is
//      * being retired but no migration of the positions are possible, or in the
//      * extreme scenario that the Strategy needs to be put into "Emergency Exit"
//      * mode in order for it to exit as quickly as possible. The latter scenario
//      * could be for any reason that is considered "critical" that the Strategy
//      * exits its position as fast as possible, such as a sudden change in
//      * market conditions leading to losses, or an imminent failure in an
//      * external dependency.
//      */
//     function revokeStrategy() external;

//     /**
//      * View the governance address of the Vault to assert privileged functions
//      * can only be called by governance. The Strategy serves the Vault, so it
//      * is subject to governance defined by the Vault.
//      */
//     function governance() external view returns (address);

//     /**
//      * View the management address of the Vault to assert privileged functions
//      * can only be called by management. The Strategy serves the Vault, so it
//      * is subject to management defined by the Vault.
//      */
//     function management() external view returns (address);

//     /**
//      * View the guardian address of the Vault to assert privileged functions
//      * can only be called by guardian. The Strategy serves the Vault, so it
//      * is subject to guardian defined by the Vault.
//      */
//     function guardian() external view returns (address);
// }

// // Part: CErc20I

// interface CErc20I is CTokenI {
//     function mint(uint256 mintAmount) external returns (uint256);

//     function redeem(uint256 redeemTokens) external returns (uint256);

//     function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

//     function borrow(uint256 borrowAmount) external returns (uint256);

//     function repayBorrow(uint256 repayAmount) external returns (uint256);

//     function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

//     function liquidateBorrow(
//         address borrower,
//         uint256 repayAmount,
//         CTokenI cTokenCollateral
//     ) external returns (uint256);

//     function underlying() external view returns (address);
// }

// // Part: ComptrollerI

// interface ComptrollerI {
//     function enterMarkets(address[] calldata cTokens) external returns (uint256[] memory);

//     function exitMarket(address cToken) external returns (uint256);

//     /*** Policy Hooks ***/

//     function mintAllowed(
//         address cToken,
//         address minter,
//         uint256 mintAmount
//     ) external returns (uint256);

//     function mintVerify(
//         address cToken,
//         address minter,
//         uint256 mintAmount,
//         uint256 mintTokens
//     ) external;

//     function redeemAllowed(
//         address cToken,
//         address redeemer,
//         uint256 redeemTokens
//     ) external returns (uint256);

//     function redeemVerify(
//         address cToken,
//         address redeemer,
//         uint256 redeemAmount,
//         uint256 redeemTokens
//     ) external;

//     function borrowAllowed(
//         address cToken,
//         address borrower,
//         uint256 borrowAmount
//     ) external returns (uint256);

//     function borrowVerify(
//         address cToken,
//         address borrower,
//         uint256 borrowAmount
//     ) external;

//     function repayBorrowAllowed(
//         address cToken,
//         address payer,
//         address borrower,
//         uint256 repayAmount
//     ) external returns (uint256);

//     function repayBorrowVerify(
//         address cToken,
//         address payer,
//         address borrower,
//         uint256 repayAmount,
//         uint256 borrowerIndex
//     ) external;

//     function liquidateBorrowAllowed(
//         address cTokenBorrowed,
//         address cTokenCollateral,
//         address liquidator,
//         address borrower,
//         uint256 repayAmount
//     ) external returns (uint256);

//     function liquidateBorrowVerify(
//         address cTokenBorrowed,
//         address cTokenCollateral,
//         address liquidator,
//         address borrower,
//         uint256 repayAmount,
//         uint256 seizeTokens
//     ) external;

//     function seizeAllowed(
//         address cTokenCollateral,
//         address cTokenBorrowed,
//         address liquidator,
//         address borrower,
//         uint256 seizeTokens
//     ) external returns (uint256);

//     function seizeVerify(
//         address cTokenCollateral,
//         address cTokenBorrowed,
//         address liquidator,
//         address borrower,
//         uint256 seizeTokens
//     ) external;

//     function transferAllowed(
//         address cToken,
//         address src,
//         address dst,
//         uint256 transferTokens
//     ) external returns (uint256);

//     function transferVerify(
//         address cToken,
//         address src,
//         address dst,
//         uint256 transferTokens
//     ) external;

//     /*** Liquidity/Liquidation Calculations ***/

//     function liquidateCalculateSeizeTokens(
//         address cTokenBorrowed,
//         address cTokenCollateral,
//         uint256 repayAmount
//     ) external view returns (uint256, uint256);

//     function getAccountLiquidity(address account)
//         external
//         view
//         returns (
//             uint256,
//             uint256,
//             uint256
//         );

//     /***  Comp claims ****/
//     function claimReward(address holder) external;

//     function claimReward(address holder, CTokenI[] memory cTokens) external;

//     function markets(address ctoken)
//         external
//         view
//         returns (
//             bool,
//             uint256,
//             bool
//         );

//     function compSpeeds(address ctoken) external view returns (uint256);
// }

// // Part: GenericLenderBase

// abstract contract GenericLenderBase is IGenericLender {
//     using SafeERC20 for IERC20;
//     VaultAPI public vault;
//     address public override strategy;
//     IERC20 public want;
//     string public override lenderName;
//     uint256 public dust;

//     event Cloned(address indexed clone);

//     constructor(address _strategy, string memory _name) public {
//         _initialize(_strategy, _name);
//     }

//     function _initialize(address _strategy, string memory _name) internal {
//         require(address(strategy) == address(0), "Lender already initialized");

//         strategy = _strategy;
//         vault = VaultAPI(IBaseStrategy(strategy).vault());
//         want = IERC20(vault.token());
//         lenderName = _name;
//         dust = 10000;

//         want.safeApprove(_strategy, uint256(-1));
//     }

//     function initialize(address _strategy, string memory _name) external virtual {
//         _initialize(_strategy, _name);
//     }

//     function _clone(address _strategy, string memory _name) internal returns (address newLender) {
//         // Copied from https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol
//         bytes20 addressBytes = bytes20(address(this));

//         assembly {
//             // EIP-1167 bytecode
//             let clone_code := mload(0x40)
//             mstore(clone_code, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
//             mstore(add(clone_code, 0x14), addressBytes)
//             mstore(add(clone_code, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
//             newLender := create(0, clone_code, 0x37)
//         }

//         GenericLenderBase(newLender).initialize(_strategy, _name);
//         emit Cloned(newLender);
//     }

//     function setDust(uint256 _dust) external virtual override management {
//         dust = _dust;
//     }

//     function sweep(address _token) external virtual override management {
//         address[] memory _protectedTokens = protectedTokens();
//         for (uint256 i; i < _protectedTokens.length; i++) require(_token != _protectedTokens[i], "!protected");

//         IERC20(_token).safeTransfer(vault.governance(), IERC20(_token).balanceOf(address(this)));
//     }

//     function protectedTokens() internal view virtual returns (address[] memory);

//     modifier management() {
//         require(
//             msg.sender == address(strategy) || msg.sender == vault.governance() || msg.sender == IBaseStrategy(strategy).management(),
//             "!management"
//         );
//         _;
//     }

//     modifier onlyGovernance() {
//         require(msg.sender == vault.governance(), "!gov");
//         _;
//     }
// }

// // File: GenericScream.sol

// /********************
//  *   A lender plugin for LenderYieldOptimiser for any erc20 asset on compound (not eth)
//  *   Made by SamPriestley.com
//  *   https://github.com/Grandthrax/yearnv2/blob/master/contracts/GenericDyDx/GenericCompound.sol
//  *
//  ********************* */

// contract GenericIron is GenericLenderBase {
//     using SafeERC20 for IERC20;
//     using Address for address;
//     using SafeMath for uint256;

//     uint256 private constant blocksPerYear = 3154 * 10**4;
//     address public constant dfynRouter = address(0xA102072A4C07F06EC3B4900FDC4C7B80b6c57429);
//     address public constant ice = address(0x4A81f8796e0c6Ad4877A51C86693B0dE8093F2ef);
//     address public constant wmatic = address(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);
//     address public constant unitroller = address(0xF20fcd005AFDd3AD48C85d0222210fe168DDd10c);

//     uint256 public dustThreshold;

//     uint256 public minIceToSell = 0 ether;

//     CErc20I public cToken;

//     bool public claimComp;

//     constructor(
//         address _strategy,
//         string memory name,
//         address _cToken
//     ) public GenericLenderBase(_strategy, name) {
//         _initialize(_cToken);
//     }

//     function initialize(address _cToken) external {
//         _initialize(_cToken);
//     }

//     function _initialize(address _cToken) internal {
//         require(address(cToken) == address(0), "GenericCream already initialized");
//         cToken = CErc20I(_cToken);
//         require(cToken.underlying() == address(want), "WRONG CTOKEN");
//         want.safeApprove(_cToken, uint256(-1));
//         IERC20(ice).safeApprove(dfynRouter, uint256(-1));
//         dustThreshold = 10_000;
//         claimComp = true; // Claim comp is on by default
//     }

//     function cloneCompoundLender(
//         address _strategy,
//         string memory _name,
//         address _cToken
//     ) external returns (address newLender) {
//         newLender = _clone(_strategy, _name);
//         GenericIron(newLender).initialize(_cToken);
//     }

//     function nav() external view override returns (uint256) {
//         return _nav();
//     }

//     //adjust dust threshol
//     function setDustThreshold(uint256 amount) external management {
//         dustThreshold = amount;
//     }

//     function _nav() internal view returns (uint256) {
//         uint256 amount = want.balanceOf(address(this)).add(underlyingBalanceStored());

//         if(amount < dustThreshold){
//             return 0;
//         }else{
//             return amount;
//         }
//     }

//     function underlyingBalanceStored() public view returns (uint256 balance) {
//         uint256 currentCr = cToken.balanceOf(address(this));
//         if (currentCr < dustThreshold) {
//             balance = 0;
//         } else {
//             //The current exchange rate as an unsigned integer, scaled by 1e18.
//             balance = currentCr.mul(cToken.exchangeRateStored()).div(1e18);
//         }
//     }

//     function apr() external view override returns (uint256) {
//         return _apr();
//     }

//     function _apr() internal view returns (uint256) {
//         return (cToken.supplyRatePerBlock().add(compBlockShareInWant(0, false))).mul(blocksPerYear);
//     }

//     function compBlockShareInWant(uint256 change, bool add) public view returns (uint256){
//         //comp speed is amount to borrow or deposit (so half the total distribution for want)
//         uint256 distributionPerBlock = ComptrollerI(unitroller).compSpeeds(address(cToken));

//         //convert to per dolla
//         uint256 totalSupply = cToken.totalSupply().mul(cToken.exchangeRateStored()).div(1e18);
//         if(add){
//             totalSupply = totalSupply.add(change);
//         }else{
//             totalSupply = totalSupply.sub(change);
//         }

//         uint256 blockShareSupply = 0;
//         if(totalSupply > 0){
//             blockShareSupply = distributionPerBlock.mul(1e18).div(totalSupply);
//         }

//         uint256 estimatedWant =  priceCheck(ice, address(want),blockShareSupply);
//         uint256 compRate;
//         if(estimatedWant != 0){
//             compRate = estimatedWant.mul(9).div(10); //10% pessimist

//         }

//         return(compRate);
//     }

//     //WARNING. manipulatable and simple routing. Only use for safe functions
//     function priceCheck(address start, address end, uint256 _amount) public view returns (uint256) {
//         if (_amount == 0) {
//             return 0;
//         }
//         address[] memory path = getTokenOutPath(start, end);
//         uint256[] memory amounts = IUniswapV2Router02(dfynRouter).getAmountsOut(_amount, path);

//         return amounts[amounts.length - 1];
//     }

//     function weightedApr() external view override returns (uint256) {
//         uint256 a = _apr();
//         return a.mul(_nav());
//     }

//     function withdraw(uint256 amount) external override management returns (uint256) {
//         return _withdraw(amount);
//     }

//     //emergency withdraw. sends balance plus amount to governance
//     function emergencyWithdraw(uint256 amount) external override management {
//         //dont care about errors here. we want to exit what we can
//         cToken.redeem(amount);

//         want.safeTransfer(vault.governance(), want.balanceOf(address(this)));
//     }

//     //withdraw an amount including any want balance
//     function _withdraw(uint256 amount) internal returns (uint256) {
//         uint256 balanceUnderlying = cToken.balanceOfUnderlying(address(this));
//         uint256 looseBalance = want.balanceOf(address(this));
//         uint256 total = balanceUnderlying.add(looseBalance);

//         if (amount.add(dustThreshold) >= total) {
//             //cant withdraw more than we own. so withdraw all we can
//             if(balanceUnderlying > dustThreshold){
//                 require(cToken.redeem(cToken.balanceOf(address(this))) == 0, "ctoken: redeemAll fail");
//             }
//             looseBalance = want.balanceOf(address(this));
//             if(looseBalance > 0 ){
//                 want.safeTransfer(address(strategy), looseBalance);
//                 return looseBalance;
//             }else{
//                 return 0;
//             }

//         }

//         if (looseBalance >= amount) {
//             want.safeTransfer(address(strategy), amount);
//             return amount;
//         }

//         //not state changing but OK because of previous call
//         uint256 liquidity = want.balanceOf(address(cToken));

//         if (liquidity > 1) {
//             uint256 toWithdraw = amount.sub(looseBalance);

//             if (toWithdraw > liquidity) {
//                 toWithdraw = liquidity;
//             }
//             if(toWithdraw > dustThreshold){
//                 require(cToken.redeemUnderlying(toWithdraw) == 0, "ctoken: redeemUnderlying fail");
//             }

//         }
//         _disposeOfComp();
//         looseBalance = want.balanceOf(address(this));
//         want.safeTransfer(address(strategy), looseBalance);
//         return looseBalance;
//     }

//     function _disposeOfComp() internal {

//         // NO-OP if we shouldn't claim
//         if (! claimComp) {
//             return;
//         }

//         CTokenI[] memory tokens = new CTokenI[](1);
//         tokens[0] = cToken;

//         ComptrollerI(unitroller).claimReward(address(this), tokens);

//         uint256 _ice = IERC20(ice).balanceOf(address(this));

//         if (_ice > minIceToSell) {
//             address[] memory path = getTokenOutPath(ice, address(want));
//             IUniswapV2Router02(dfynRouter).swapExactTokensForTokens(_ice, uint256(0), path, address(this), now);
//         }
//     }

//     function getTokenOutPath(address _token_in, address _token_out) internal pure returns (address[] memory _path) {
//         bool is_wmatic = _token_in == address(wmatic) || _token_out == address(wmatic);
//         _path = new address[](is_wmatic ? 2 : 3);
//         _path[0] = _token_in;
//         if (is_wmatic) {
//             _path[1] = _token_out;
//         } else {
//             _path[1] = address(wmatic);
//             _path[2] = _token_out;
//         }
//     }

//     function deposit() external override management {
//         uint256 balance = want.balanceOf(address(this));
//         require(cToken.mint(balance) == 0, "ctoken: mint fail");
//     }

//     function withdrawAll() external override management returns (bool) {
//         //redo or else price changes
//         cToken.mint(0);

//         uint256 liquidity = want.balanceOf(address(cToken));
//         uint256 liquidityInCTokens = convertFromUnderlying(liquidity);
//         uint256 amountInCtokens = cToken.balanceOf(address(this));

//         bool all;

//         if (liquidityInCTokens > 2) {
//             liquidityInCTokens = liquidityInCTokens-1;

//             if (amountInCtokens <= liquidityInCTokens) {
//                 //we can take all
//                 all = true;
//                 cToken.redeem(amountInCtokens);
//             } else {
//                 liquidityInCTokens = convertFromUnderlying(want.balanceOf(address(cToken)));
//                 //take all we can
//                 all = false;
//                 cToken.redeem(liquidityInCTokens);
//             }
//         }

//         want.safeTransfer(address(strategy), want.balanceOf(address(this)));
//         return all;
//     }

//     function convertFromUnderlying(uint256 amountOfUnderlying) public view returns (uint256 balance){
//         if (amountOfUnderlying == 0) {
//             balance = 0;
//         } else {
//             balance = amountOfUnderlying.mul(1e18).div(cToken.exchangeRateStored());
//         }
//     }

//     function hasAssets() external view override returns (bool) {
//         //return cToken.balanceOf(address(this)) > 0;
//         return cToken.balanceOf(address(this)) > dustThreshold || want.balanceOf(address(this)) > 0;
//     }

//     function aprAfterDeposit(uint256 amount) external view override returns (uint256) {
//         uint256 cashPrior = want.balanceOf(address(cToken));

//         uint256 borrows = cToken.totalBorrows();

//         uint256 reserves = cToken.totalReserves();

//         uint256 reserverFactor = cToken.reserveFactorMantissa();

//         InterestRateModel model = cToken.interestRateModel();

//         //the supply rate is derived from the borrow rate, reserve factor and the amount of total borrows.
//         uint256 supplyRate = model.getSupplyRate(cashPrior.add(amount), borrows, reserves, reserverFactor);
//         supplyRate = supplyRate.add(compBlockShareInWant(amount, true));

//         return supplyRate.mul(blocksPerYear);
//     }

//     function protectedTokens() internal view override returns (address[] memory) {
//         address[] memory protected = new address[](3);
//         protected[0] = address(want);
//         protected[1] = address(cToken);
//         protected[2] = ice;
//         return protected;
//     }

//     function setClaimComp(bool _claimComp) external management {
//         claimComp = _claimComp;
//     }
// }