// /**
//  *Submitted for verification at Etherscan.io on 2021-09-25
//  https://etherscan.io/address/0x7c1612476D235c8054253c83B98f7Ca6f7F2E9D0#code
//  https://etherscan.io/address/0x9cfF0533972da48Ac05a00a375CC1a65e87Da7eC#code
// */

// // SPDX-License-Identifier: AGPL-3.0

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

// // Part: IAsset

// interface IAsset {
//     // solhint-disable-previous-line no-empty-blocks
// }

// // Part: yearn/yearn-vaults@0.4.3/HealthCheck

// interface HealthCheck {
//     function check(
//         uint256 profit,
//         uint256 loss,
//         uint256 debtPayment,
//         uint256 debtOutstanding,
//         uint256 totalDebt
//     ) external view returns (bool);
// }

// // Part: IBalancerPool

// interface IBalancerPool is IERC20 {
//     enum SwapKind {GIVEN_IN, GIVEN_OUT}

//     struct SwapRequest {
//         SwapKind kind;
//         IERC20 tokenIn;
//         IERC20 tokenOut;
//         uint256 amount;
//         // Misc data
//         bytes32 poolId;
//         uint256 lastChangeBlock;
//         address from;
//         address to;
//         bytes userData;
//     }

//     function getPoolId() external view returns (bytes32 poolId);

//     function symbol() external view returns (string memory s);

//     function onSwap(
//         SwapRequest memory swapRequest,
//         uint256[] memory balances,
//         uint256 indexIn,
//         uint256 indexOut
//     ) external view returns (uint256 amount);
// }

// // Part: IBalancerVault

// interface IBalancerVault {
//     enum PoolSpecialization {GENERAL, MINIMAL_SWAP_INFO, TWO_TOKEN}
//     enum JoinKind {INIT, EXACT_TOKENS_IN_FOR_BPT_OUT, TOKEN_IN_FOR_EXACT_BPT_OUT, ALL_TOKENS_IN_FOR_EXACT_BPT_OUT}
//     enum ExitKind {EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, EXACT_BPT_IN_FOR_TOKENS_OUT, BPT_IN_FOR_EXACT_TOKENS_OUT}
//     enum SwapKind {GIVEN_IN, GIVEN_OUT}

//     /**
//      * @dev Data for each individual swap executed by `batchSwap`. The asset in and out fields are indexes into the
//      * `assets` array passed to that function, and ETH assets are converted to WETH.
//      *
//      * If `amount` is zero, the multihop mechanism is used to determine the actual amount based on the amount in/out
//      * from the previous swap, depending on the swap kind.
//      *
//      * The `userData` field is ignored by the Vault, but forwarded to the Pool in the `onSwap` hook, and may be
//      * used to extend swap behavior.
//      */
//     struct BatchSwapStep {
//         bytes32 poolId;
//         uint256 assetInIndex;
//         uint256 assetOutIndex;
//         uint256 amount;
//         bytes userData;
//     }
//     /**
//      * @dev All tokens in a swap are either sent from the `sender` account to the Vault, or from the Vault to the
//      * `recipient` account.
//      *
//      * If the caller is not `sender`, it must be an authorized relayer for them.
//      *
//      * If `fromInternalBalance` is true, the `sender`'s Internal Balance will be preferred, performing an ERC20
//      * transfer for the difference between the requested amount and the User's Internal Balance (if any). The `sender`
//      * must have allowed the Vault to use their tokens via `IERC20.approve()`. This matches the behavior of
//      * `joinPool`.
//      *
//      * If `toInternalBalance` is true, tokens will be deposited to `recipient`'s internal balance instead of
//      * transferred. This matches the behavior of `exitPool`.
//      *
//      * Note that ETH cannot be deposited to or withdrawn from Internal Balance: attempting to do so will trigger a
//      * revert.
//      */
//     struct FundManagement {
//         address sender;
//         bool fromInternalBalance;
//         address payable recipient;
//         bool toInternalBalance;
//     }

//     /**
//      * @dev Data for a single swap executed by `swap`. `amount` is either `amountIn` or `amountOut` depending on
//      * the `kind` value.
//      *
//      * `assetIn` and `assetOut` are either token addresses, or the IAsset sentinel value for ETH (the zero address).
//      * Note that Pools never interact with ETH directly: it will be wrapped to or unwrapped from WETH by the Vault.
//      *
//      * The `userData` field is ignored by the Vault, but forwarded to the Pool in the `onSwap` hook, and may be
//      * used to extend swap behavior.
//      */
//     struct SingleSwap {
//         bytes32 poolId;
//         SwapKind kind;
//         IAsset assetIn;
//         IAsset assetOut;
//         uint256 amount;
//         bytes userData;
//     }

//     // enconding formats https://github.com/balancer-labs/balancer-v2-monorepo/blob/master/pkg/balancer-js/src/pool-weighted/encoder.ts
//     struct JoinPoolRequest {
//         IAsset[] assets;
//         uint256[] maxAmountsIn;
//         bytes userData;
//         bool fromInternalBalance;
//     }

//     struct ExitPoolRequest {
//         IAsset[] assets;
//         uint256[] minAmountsOut;
//         bytes userData;
//         bool toInternalBalance;
//     }

//     function joinPool(
//         bytes32 poolId,
//         address sender,
//         address recipient,
//         JoinPoolRequest memory request
//     ) external payable;

//     function exitPool(
//         bytes32 poolId,
//         address sender,
//         address payable recipient,
//         ExitPoolRequest calldata request
//     ) external;

//     function getPool(bytes32 poolId) external view returns (address poolAddress, PoolSpecialization);

//     function getPoolTokenInfo(bytes32 poolId, IERC20 token) external view returns (
//         uint256 cash,
//         uint256 managed,
//         uint256 lastChangeBlock,
//         address assetManager
//     );

//     function getPoolTokens(bytes32 poolId) external view returns (
//         IERC20[] calldata tokens,
//         uint256[] calldata balances,
//         uint256 lastChangeBlock
//     );
//     /**
//      * @dev Performs a swap with a single Pool.
//      *
//      * If the swap is 'given in' (the number of tokens to send to the Pool is known), it returns the amount of tokens
//      * taken from the Pool, which must be greater than or equal to `limit`.
//      *
//      * If the swap is 'given out' (the number of tokens to take from the Pool is known), it returns the amount of tokens
//      * sent to the Pool, which must be less than or equal to `limit`.
//      *
//      * Internal Balance usage and the recipient are determined by the `funds` struct.
//      *
//      * Emits a `Swap` event.
//      */
//     function swap(
//         SingleSwap memory singleSwap,
//         FundManagement memory funds,
//         uint256 limit,
//         uint256 deadline
//     ) external returns (uint256 amountCalculated);

//     /**
//      * @dev Performs a series of swaps with one or multiple Pools. In each individual swap, the caller determines either
//      * the amount of tokens sent to or received from the Pool, depending on the `kind` value.
//      *
//      * Returns an array with the net Vault asset balance deltas. Positive amounts represent tokens (or ETH) sent to the
//      * Vault, and negative amounts represent tokens (or ETH) sent by the Vault. Each delta corresponds to the asset at
//      * the same index in the `assets` array.
//      *
//      * Swaps are executed sequentially, in the order specified by the `swaps` array. Each array element describes a
//      * Pool, the token to be sent to this Pool, the token to receive from it, and an amount that is either `amountIn` or
//      * `amountOut` depending on the swap kind.
//      *
//      * Multihop swaps can be executed by passing an `amount` value of zero for a swap. This will cause the amount in/out
//      * of the previous swap to be used as the amount in for the current one. In a 'given in' swap, 'tokenIn' must equal
//      * the previous swap's `tokenOut`. For a 'given out' swap, `tokenOut` must equal the previous swap's `tokenIn`.
//      *
//      * The `assets` array contains the addresses of all assets involved in the swaps. These are either token addresses,
//      * or the IAsset sentinel value for ETH (the zero address). Each entry in the `swaps` array specifies tokens in and
//      * out by referencing an index in `assets`. Note that Pools never interact with ETH directly: it will be wrapped to
//      * or unwrapped from WETH by the Vault.
//      *
//      * Internal Balance usage, sender, and recipient are determined by the `funds` struct. The `limits` array specifies
//      * the minimum or maximum amount of each token the vault is allowed to transfer.
//      *
//      * `batchSwap` can be used to make a single swap, like `swap` does, but doing so requires more gas than the
//      * equivalent `swap` call.
//      *
//      * Emits `Swap` events.
//      */
//     function batchSwap(
//         SwapKind kind,
//         BatchSwapStep[] memory swaps,
//         IAsset[] memory assets,
//         FundManagement memory funds,
//         int256[] memory limits,
//         uint256 deadline
//     ) external payable returns (int256[] memory);
// }

// // Part: yearn/yearn-vaults@0.4.3/VaultAPI

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

// // Part: yearn/yearn-vaults@0.4.3/BaseStrategy
// import {BaseStrategyInitializable, BaseStrategy} from "../BaseStrategy.sol";
// import {SafeERC20, SafeMath, IERC20, Address} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {Math} from "@openzeppelin/contracts/math/Math.sol";

// // File: Strategy.sol

// contract Strategy is BaseStrategy {
//     using SafeERC20 for IERC20;
//     using Address for address;
//     using SafeMath for uint256;

//     IERC20 internal constant weth = IERC20(address(0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270));
//     IBalancerVault public balancerVault;
//     IBalancerPool public bpt;
//     IERC20[] public rewardTokens;
//     IAsset[] internal assets;
//     SwapSteps[] internal swapSteps;
//     uint256[] internal minAmountsOut;
//     bytes32 public balancerPoolId;
//     uint8 public numTokens;
//     uint8 public tokenIndex;

//     struct SwapSteps {
//         bytes32[] poolIds;
//         IAsset[] assets;
//     }

//     uint256 internal constant max = type(uint256).max;

//     //1	    0.01%
//     //5	    0.05%
//     //10	0.1%
//     //50	0.5%
//     //100	1%
//     //1000	10%
//     //10000	100%
//     uint256 public maxSlippageIn; // bips
//     uint256 public maxSlippageOut; // bips
//     uint256 public maxSingleDeposit;
//     uint256 public minDepositPeriod; // seconds
//     uint256 public lastDepositTime;
//     uint256 internal constant basisOne = 10000;
//     bool internal isOriginal = true;

//     constructor(
//         address _vault,
//         address _balancerVault,
//         address _balancerPool,
//         uint256 _maxSlippageIn,
//         uint256 _maxSlippageOut,
//         uint256 _maxSingleDeposit,
//         uint256 _minDepositPeriod)
//     public BaseStrategy(_vault){
//         _initializeStrat(_vault, _balancerVault, _balancerPool, _maxSlippageIn, _maxSlippageOut, _maxSingleDeposit, _minDepositPeriod);
//     }

//     function initialize(
//         address _vault,
//         address _strategist,
//         address _rewards,
//         address _keeper,
//         address _balancerVault,
//         address _balancerPool,
//         uint256 _maxSlippageIn,
//         uint256 _maxSlippageOut,
//         uint256 _maxSingleDeposit,
//         uint256 _minDepositPeriod
//     ) external {
//         _initialize(_vault, _strategist, _rewards, _keeper);
//         _initializeStrat(_vault, _balancerVault, _balancerPool, _maxSlippageIn, _maxSlippageOut, _maxSingleDeposit, _minDepositPeriod);
//     }

//     function _initializeStrat(
//         address _vault,
//         address _balancerVault,
//         address _balancerPool,
//         uint256 _maxSlippageIn,
//         uint256 _maxSlippageOut,
//         uint256 _maxSingleDeposit,
//         uint256 _minDepositPeriod)
//     internal {
//         require(address(bpt) == address(0x0), "Strategy already initialized!");
//         // healthCheck = address(0xDDCea799fF1699e98EDF118e0629A974Df7DF012); // health.ychad.eth
//         bpt = IBalancerPool(_balancerPool);
//         balancerPoolId = bpt.getPoolId();
//         balancerVault = IBalancerVault(_balancerVault);
//         (IERC20[] memory tokens,,) = balancerVault.getPoolTokens(balancerPoolId);
//         numTokens = uint8(tokens.length);
//         assets = new IAsset[](numTokens);
//         tokenIndex = type(uint8).max;
//         for (uint8 i = 0; i < numTokens; i++) {
//             if (tokens[i] == want) {
//                 tokenIndex = i;
//             }
//             assets[i] = IAsset(address(tokens[i]));
//         }
//         require(tokenIndex != type(uint8).max, "token not supported in pool!");

//         maxSlippageIn = _maxSlippageIn;
//         maxSlippageOut = _maxSlippageOut;
//         maxSingleDeposit = _maxSingleDeposit.mul(10 ** uint256(ERC20(address(want)).decimals()));
//         minAmountsOut = new uint256[](numTokens);
//         minDepositPeriod = _minDepositPeriod;

//         want.safeApprove(address(balancerVault), max);
//     }

//     event Cloned(address indexed clone);

//     function clone(
//         address _vault,
//         address _strategist,
//         address _rewards,
//         address _keeper,
//         address _balancerVault,
//         address _balancerPool,
//         uint256 _maxSlippageIn,
//         uint256 _maxSlippageOut,
//         uint256 _maxSingleDeposit,
//         uint256 _minDepositPeriod
//     ) external returns (address payable newStrategy) {
//         require(isOriginal);

//         bytes20 addressBytes = bytes20(address(this));

//         assembly {
//         // EIP-1167 bytecode
//             let clone_code := mload(0x40)
//             mstore(clone_code, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
//             mstore(add(clone_code, 0x14), addressBytes)
//             mstore(add(clone_code, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
//             newStrategy := create(0, clone_code, 0x37)
//         }

//         Strategy(newStrategy).initialize(
//             _vault, _strategist, _rewards, _keeper, _balancerVault, _balancerPool, _maxSlippageIn, _maxSlippageOut, _maxSingleDeposit, _minDepositPeriod
//         );

//         emit Cloned(newStrategy);
//     }


//     // ******** OVERRIDE THESE METHODS FROM BASE CONTRACT ************

//     function name() external view override returns (string memory) {
//         // Add your own name here, suggestion e.g. "StrategyCreamYFI"
//         return string(abi.encodePacked("SingleSidedBalancer ", bpt.symbol(), "Pool ", ERC20(address(want)).symbol()));
//     }

//     function estimatedTotalAssets() public view override returns (uint256) {
//         return balanceOfWant().add(balanceOfPooled());
//     }

//     function prepareReturn(uint256 _debtOutstanding) internal override returns (uint256 _profit, uint256 _loss, uint256 _debtPayment){
//         if (_debtOutstanding > 0) {
//             (_debtPayment, _loss) = liquidatePosition(_debtOutstanding);
//         }

//         uint256 beforeWant = balanceOfWant();

//         // 2 forms of profit. Incentivized rewards (BAL+other) and pool fees (want)
//         collectTradingFees();
//         sellRewards();

//         uint256 afterWant = balanceOfWant();

//         _profit = afterWant.sub(beforeWant);
//         if (_profit > _loss) {
//             _profit = _profit.sub(_loss);
//             _loss = 0;
//         } else {
//             _loss = _loss.sub(_profit);
//             _profit = 0;
//         }
//     }

//     function adjustPosition(uint256 _debtOutstanding) internal override {
//         if (now - lastDepositTime < minDepositPeriod) {
//             return;
//         }

//         uint256 pooledBefore = balanceOfPooled();
//         uint256[] memory maxAmountsIn = new uint256[](numTokens);
//         uint256 amountIn = Math.min(maxSingleDeposit, balanceOfWant());
//         maxAmountsIn[tokenIndex] = amountIn;

//         if (maxAmountsIn[tokenIndex] > 0) {
//             uint256[] memory amountsIn = new uint256[](numTokens);
//             amountsIn[tokenIndex] = amountIn;
//             bytes memory userData = abi.encode(IBalancerVault.JoinKind.EXACT_TOKENS_IN_FOR_BPT_OUT, amountsIn, 0);
//             IBalancerVault.JoinPoolRequest memory request = IBalancerVault.JoinPoolRequest(assets, maxAmountsIn, userData, false);
//             balancerVault.joinPool(balancerPoolId, address(this), address(this), request);

//             uint256 pooledDelta = balanceOfPooled().sub(pooledBefore);
//             uint256 joinSlipped = amountIn > pooledDelta ? amountIn.sub(pooledDelta) : 0;
//             uint256 maxLoss = amountIn.mul(maxSlippageIn).div(basisOne);

//             require(joinSlipped <= maxLoss, "Exceeded maxSlippageIn!");
//             lastDepositTime = now;
//         }
//     }

//     function liquidatePosition(uint256 _amountNeeded) internal override returns (uint256 _liquidatedAmount, uint256 _loss){
//         if (estimatedTotalAssets() < _amountNeeded) {
//             _liquidatedAmount = liquidateAllPositions();
//             return (_liquidatedAmount, _amountNeeded.sub(_liquidatedAmount));
//         }

//         uint256 looseAmount = balanceOfWant();
//         if (_amountNeeded > looseAmount) {
//             uint256 toExitAmount = _amountNeeded.sub(looseAmount);

//             _sellBptForExactToken(toExitAmount);

//             _liquidatedAmount = Math.min(balanceOfWant(), _amountNeeded);
//             _loss = _amountNeeded.sub(_liquidatedAmount);

//             _enforceSlippageOut(toExitAmount, _liquidatedAmount.sub(looseAmount));
//         } else {
//             _liquidatedAmount = _amountNeeded;
//         }
//     }

//     function liquidateAllPositions() internal override returns (uint256 liquidated) {
//         uint eta = estimatedTotalAssets();
//         uint256 bpts = balanceOfBpt();
//         if (bpts > 0) {
//             // exit entire position for single token. Could revert due to single exit limit enforced by balancer
//             bytes memory userData = abi.encode(IBalancerVault.ExitKind.EXACT_BPT_IN_FOR_ONE_TOKEN_OUT, bpts, tokenIndex);
//             IBalancerVault.ExitPoolRequest memory request = IBalancerVault.ExitPoolRequest(assets, minAmountsOut, userData, false);
//             balancerVault.exitPool(balancerPoolId, address(this), address(this), request);
//         }

//         liquidated = balanceOfWant();
//         _enforceSlippageOut(eta, liquidated);
//         return liquidated;
//     }

//     function prepareMigration(address _newStrategy) internal override {
//         bpt.transfer(_newStrategy, balanceOfBpt());
//         for (uint i = 0; i < rewardTokens.length; i++) {
//             IERC20 token = rewardTokens[i];
//             uint256 balance = token.balanceOf(address(this));
//             if (balance > 0) {
//                 token.transfer(_newStrategy, balance);
//             }
//         }
//     }

//     function protectedTokens() internal view override returns (address[] memory){}

//     function ethToWant(uint256 _amtInWei) public view override returns (uint256){}

//     function tendTrigger(uint256 callCostInWei) public view override returns (bool) {
//         return now.sub(lastDepositTime) > minDepositPeriod && balanceOfWant() > 0;
//     }

//     function harvestTrigger(uint256 callCostInWei) public view override returns (bool){
//         bool hasRewards;
//         for (uint8 i = 0; i < rewardTokens.length; i++) {
//             ERC20 rewardToken = ERC20(address(rewardTokens[i]));

//             uint decReward = rewardToken.decimals();
//             uint decWant = ERC20(address(want)).decimals();
//             if (rewardToken.balanceOf(address(this)) > 10 ** (decReward > decWant ? decReward.sub(decWant) : 0)) {
//                 hasRewards = true;
//                 break;
//             }
//         }
//         return super.harvestTrigger(callCostInWei) && hasRewards;
//     }


//     // HELPERS //
//     function sellRewards() internal {
//         for (uint8 i = 0; i < rewardTokens.length; i++) {
//             ERC20 rewardToken = ERC20(address(rewardTokens[i]));
//             uint256 amount = rewardToken.balanceOf(address(this));

//             uint decReward = rewardToken.decimals();
//             uint decWant = ERC20(address(want)).decimals();

//             if (amount > 10 ** (decReward > decWant ? decReward.sub(decWant) : 0)) {
//                 uint length = swapSteps[i].poolIds.length;
//                 IBalancerVault.BatchSwapStep[] memory steps = new IBalancerVault.BatchSwapStep[](length);
//                 int[] memory limits = new int[](length + 1);
//                 limits[0] = int(amount);
//                 for (uint j = 0; j < length; j++) {
//                     steps[j] = IBalancerVault.BatchSwapStep(swapSteps[i].poolIds[j],
//                         j,
//                         j + 1,
//                         j == 0 ? amount : 0,
//                         abi.encode(0)
//                     );
//                 }
//                 balancerVault.batchSwap(IBalancerVault.SwapKind.GIVEN_IN,
//                     steps,
//                     swapSteps[i].assets,
//                     IBalancerVault.FundManagement(address(this), false, address(this), false),
//                     limits,
//                     now + 10);
//             }
//         }
//     }

//     function collectTradingFees() internal {
//         uint256 total = estimatedTotalAssets();
//         uint256 debt = vault.strategies(address(this)).totalDebt;
//         if (total > debt) {
//             uint256 profit = total.sub(debt);
//             _sellBptForExactToken(profit);
//         }
//     }

//     function balanceOfWant() public view returns (uint256 _amount){
//         return want.balanceOf(address(this));
//     }

//     function balanceOfBpt() public view returns (uint256 _amount){
//         return bpt.balanceOf(address(this));
//     }

//     function balanceOfReward(uint256 index) public view returns (uint256 _amount){
//         return rewardTokens[index].balanceOf(address(this));
//     }

//     function balanceOfPooled() public view returns (uint256 _amount){
//         uint256 totalWantPooled;
//         (IERC20[] memory tokens,uint256[] memory totalBalances,uint256 lastChangeBlock) = balancerVault.getPoolTokens(balancerPoolId);
//         for (uint8 i = 0; i < numTokens; i++) {
//             uint256 tokenPooled = totalBalances[i].mul(balanceOfBpt()).div(bpt.totalSupply());
//             if (tokenPooled > 0) {
//                 IERC20 token = tokens[i];
//                 if (token != want) {
//                     IBalancerPool.SwapRequest memory request = _getSwapRequest(token, tokenPooled, lastChangeBlock);
//                     // now denomated in want
//                     tokenPooled = bpt.onSwap(request, totalBalances, i, tokenIndex);
//                 }
//                 totalWantPooled += tokenPooled;
//             }
//         }
//         return totalWantPooled;
//     }

//     function _getSwapRequest(IERC20 token, uint256 amount, uint256 lastChangeBlock) internal view returns (IBalancerPool.SwapRequest memory request){
//         return IBalancerPool.SwapRequest(IBalancerPool.SwapKind.GIVEN_IN,
//             token,
//             want,
//             amount,
//             balancerPoolId,
//             lastChangeBlock,
//             address(this),
//             address(this),
//             abi.encode(0)
//         );
//     }

//     function _sellBptForExactToken(uint256 _amountTokenOut) internal {
//         uint256[] memory amountsOut = new uint256[](numTokens);
//         amountsOut[tokenIndex] = _amountTokenOut;
//         bytes memory userData = abi.encode(IBalancerVault.ExitKind.BPT_IN_FOR_EXACT_TOKENS_OUT, amountsOut, balanceOfBpt());
//         IBalancerVault.ExitPoolRequest memory request = IBalancerVault.ExitPoolRequest(assets, minAmountsOut, userData, false);
//         balancerVault.exitPool(balancerPoolId, address(this), address(this), request);
//     }

//     // for partnership rewards like Lido or airdrops
//     function whitelistRewards(address _rewardToken, SwapSteps memory _steps) public onlyVaultManagers {
//         IERC20 token = IERC20(_rewardToken);
//         token.approve(address(balancerVault), max);
//         rewardTokens.push(token);
//         swapSteps.push(_steps);
//     }

//     function delistAllRewards() public onlyVaultManagers {
//         for (uint i = 0; i < rewardTokens.length; i++) {
//             rewardTokens[i].approve(address(balancerVault), 0);
//         }
//         IERC20[] memory noRewardTokens;
//         rewardTokens = noRewardTokens;
//         delete swapSteps;
//     }

//     function numRewards() public view returns (uint256 _num){
//         return rewardTokens.length;
//     }

//     function setParams(uint256 _maxSlippageIn, uint256 _maxSlippageOut, uint256 _maxSingleDeposit, uint256 _minDepositPeriod) public onlyVaultManagers {
//         require(_maxSlippageIn <= basisOne, "maxSlippageIn too high");
//         maxSlippageIn = _maxSlippageIn;

//         require(_maxSlippageOut <= basisOne, "maxSlippageOut too high");
//         maxSlippageOut = _maxSlippageOut;

//         maxSingleDeposit = _maxSingleDeposit;
//         minDepositPeriod = _minDepositPeriod;
//     }

//     function _enforceSlippageOut(uint _intended, uint _actual) internal {
//         // enforce that amount exited didn't slip beyond our tolerance
//         // just in case there's positive slippage
//         uint256 exitSlipped = _intended > _actual ? _intended.sub(_actual) : 0;
//         uint256 maxLoss = _intended.mul(maxSlippageOut).div(basisOne);
//         require(exitSlipped <= maxLoss, "Exceeded maxSlippageOut!");
//     }

//     function getSwapSteps() public view returns (SwapSteps[] memory){
//         return swapSteps;
//     }

//     receive() external payable {}
// }