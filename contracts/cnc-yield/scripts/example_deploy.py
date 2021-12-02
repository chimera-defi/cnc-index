# tetu iron fold
# https://polygonscan.com/address/0x289af553812908d96f4df30079d20d0d8537e3d8#code

acct = accounts.load('priv key')

from brownie.network.gas.strategies import LinearScalingStrategy
gas_strategy = LinearScalingStrategy("40 gwei", "150 gwei", 1.1, time_duration=10)

opts = {'from': acct, 'gas_price': gas_strategy}


usdc = '0x2791bca1f2de4661ed88a30c99a7a9449aa84174'
dai = '0x8f3cf7ad23cd3cadbd9735aff958023239c6a063'
weth = '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619'
wbtc = '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6'
wmatic = '0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270'

icmatic = '0xca0f37f73174a28a64552d426590d3ed601ecca1'

gelato_keepers = '0x527a819db1eb0e34426297b03bae11F2f8B3A19E'
stratFacade = '0xB31929bEC89Ba33A977147e223020Dd4b3b821e1'
sf = StrategyFacade.at(stratFacade)
# 0xdf2F57d1Fd6c1d9E92BD7162B622355aa8AF8De1 = vault
# polygonscan api key https://polygonscan.com/G1X5SQKMHU62NY4D7DIRASHYXI5NPWCCVU
one_mill = 1000000
limit_muls = {
  'usdc': 1e6,
  'dai': 1e18,
  'weth': 0.00025*1e18,
  'wbtc': (1/60000)*1e8,
  'wmatic': (1/1.5)*1e18
}
intokens = {
  'usdc': usdc,
  'dai': dai,
  'wbtc': wbtc,
  'wmatic': wmatic,
  'weth': weth
}
registry = Registry.at('0xAa5893679788E1FAE460Ae6A96791a712FDC474F')
gaurdian = acct.address
governance = acct.address
rewards = acct.address
multisig = '0x60a7188452a1CEA170CB205333AD08e8a280e494'

debtRatio = 10000  # this is max / 100% or 10k in BPS. for more strats, set this properly
minDebtPerHarvest = 0
# Hmm.. max uint256
maxDebtPerHarvest = "115792089237316195423570985008687907853269984665640564039457584007913129639935"
performanceFee = 1000

res_vaults = {}
res_strats = {}

def deployVault(name):
  vault_name = '%s-vault' % name
  vaultsym = 'ac%s' % name
  txn_receipt = registry.newExperimentalVault(intokens[name], governance, gaurdian, rewards, vault_name, vaultsym, opts)
  vault = Vault.at(txn_receipt.events["NewExperimentalVault"]["vault"])

  res_vaults[name] = vault
  return vault

strat = StratYieldRedirectAAVE.deploy(vault.address, opts)
strat.setMasterChefRewarder(acct.address)




def deployLevAAVE(name):
  vault_name = '%s-vault' % name
  vaultsym = 'ac%s' % name
  txn_receipt = registry.newExperimentalVault(intokens[name], governance, gaurdian, rewards, vault_name, vaultsym, opts)
  vault = Vault.at(txn_receipt.events["NewExperimentalVault"]["vault"])

  res_vaults[name] = vault

  strat = StrategyLeveragedAAVE.deploy(vault.address, opts, publish_source=True)
  res_strats[name] = strat

  tx = vault.addStrategy(
    strat.address,
    debtRatio,
    minDebtPerHarvest,
    maxDebtPerHarvest,
    performanceFee, opts
  )
  vault.setDepositLimit(one_mill * limit_muls[name], opts)

  sf.addStrategy(strat.address, opts)
  strat.setKeeper(sf.address, opts)





registry.newRelease( <vault> )

registry.newExperimentalVault('0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270', '0xa1feaF41d843d53d0F6bEd86a8cF592cE21C409e', '0xa1feaF41d843d53d0F6bEd86a8cF592cE21C409e', '0xa1feaF41d843d53d0F6bEd86a8cF592cE21C409e', 'Wmatic-vault', 'acmatic', opts)


#     token: address,
#     governance: address,
#     guardian: address,
#     rewards: address,
#     name: String[64],
#     symbol: String[32],
registry.newExperimentalVault()

# we want 
# usdc, dai, usdt, matic, eth, wbtc 


# strat gets want and auto resolves for genAave

# try forwarder - 0xb572710eb310f62406cea9b6bbee2699aa480e8d
# StrategyLeveragedAAVE.deploy('0xb572710eb310f62406cea9b6bbee2699aa480e8d', opts, publish_source=True)
# strat = 0x44136fc5A224D0567e5C57a1bdd4729533d7e1B8

# def addStrategy(
#     strategy: address,
#     debtRatio: uint256,
#     minDebtPerHarvest: uint256,
#     maxDebtPerHarvest: uint256,
#     performanceFee: uint256,
#     profitLimitRatio: uint256 = 100, # 1%
#     lossLimitRatio: uint256 = 1 # 0.01%
# ):

debtRatio = 10000
minDebtPerHarvest = 0
# Hmm.. max uint256
maxDebtPerHarvest = "115792089237316195423570985008687907853269984665640564039457584007913129639935"
performanceFee = 1000

vault = Vault.at('0xb572710eb310f62406cea9b6bbee2699aa480e8d')

vault.addStrategy(
  strat,
  debtRatio,
  minDebtPerHarvest,
  maxDebtPerHarvest,
  performanceFee, opts
)


v.addStrategy()

StrategyGenLevAAVE.deploy(<vault address>, {'from': acct}, publish_source=True)

# for each vault we also want a genCompLender for iron finance 

# How does harvest work here

# StrategyLeveragedAAVE
#   StrategyLeveragedAAVE deployed at: 0x1cEaD31efFafA68B77A72d56C72D9Cc163008B39

  # StrategyLeveragedAAVE deployed at: 0x9CF8EB199129c778B474E8d09574e6002bBC0Ee0

# StrategyFacade.deploy({'from': acct}, publish_source=True)
StrategyFacade.deploy(opts, publish_source=True)
# addStrategy for each vault each 
sf = StrategyFacade.at(<StrategyFacade>)
  # StrategyFacade deployed at: 0xA23179BE88887804f319C047E88FDd4dD4867eF5

StrategyResolver.deploy(<StrategyFacade>, opts, publish_source=True)

sf.addStrategy('0xc5B264f0757B4f7f4809d3Fc388591FE0C2fdd4f', opts)
sf.addResolver('0x003102998A8Dcf0B2D184da8AD2f7C46C4aDB502', opts)
  # StrategyResolver deployed at: 0xc5B264f0757B4f7f4809d3Fc388591FE0C2fdd4f

# REwards
# we also want a masterchef and want to create pools in it

# what do we do with the token? no supply cap for now and just mint to fund distributor
# may need to deploy MC etc from a different location due to version mismatch

FundDistributor.deploy(<reward address>, {'from': acct}, publish_source=True)


        # IERC20 _reward,
        # IFundDistributor _fund,
        # ITokenUtilityModule _tum
Masterchef.deploy(<FundDistributor address>, {'from': acct}, publish_source=True)



# set up pools for all the deployed token vaults 

# then look into olympus dao 



<StrategyFacade Contract '0x6ab6762C582ceda12D7edaDaf6AF72f58eaE0B29'>
<StrategyLeveragedAAVE Contract '0x9CF8EB199129c778B474E8d09574e6002bBC0Ee0'>
>>> s.vault()
'0xb572710EB310f62406CEa9B6bbee2699aa480e8d'

>>> sf.resolver()
'0x003102998A8Dcf0B2D184da8AD2f7C46C4aDB502'

StrategyLeveragedAAVE
0x1437D55C4b9D0580026DF5D0Cde22457614Cb9c3

harvest manual
0xe4e78db81ef2a919d69a732921c4c94fbb1615fb9e0b327263a86f5d825ae87d




resolver = 0x003102998A8Dcf0B2D184da8AD2f7C46C4aDB502


resolver and facade = 
0x6839d678A60B09Ffd5ccC6002a4A8d77c720df7E


strats = ['0x053a3CebE6C234ADC12AA9666a1cf7e58bcCf0Dc', '0x433614acD3a5B2f1c8A0Da5aA1Fd7eaf9cB2Ed2e', '0x795CC0cB5620614298306118478d07183d1ca8b8']
sf = StrategyFacade.deploy(opts, publish_source=True)
sf.setInterval(900)
for s in strats:
  sf.addStrategy(s)
  strat = StrategyLeveragedAAVE.at(s)
  strat.setKeeper(sf.address, opts)
sf.setResolver('0x527a819db1eb0e34426297b03bae11F2f8B3A19E')




  Storage deployed at: 0xC745545FD32167c006c994109273D0e89Dd3E0DB
  PotPool deployed at: 0x513DAfF5db6aCeE73Fe87387A4B737190F5c366c

  PotPool.deploy(
    ['0x4e78011ce80ee02d2c3e649fb657e45898257815'], # klima rewards
    '0xb65f32408ebe463248396933ccce846c06c7a9fc', # acusd
    [acct.address], # rewards
    '0xC745545FD32167c006c994109273D0e89Dd3E0DB',
    'yieldRedirectTestPotPool',
    'yrtpp',
    6,
    opts,
    publish_source=True
  )



# cache - working deploy

vault = '0xb65f32408ebe463248396933ccce846c06c7a9fc'

klima = '0x4e78011Ce80ee02d2c3e649Fb657E45898257815'
strat = '0xa06bBe2a3F5b748D2DA7363E93cB010de67890C3'
polygon_sushi_router = '0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506'

mr = '0xA1409F29361b600561582C7B337aA22E47f1c88E'

yd = YieldRedirector.deploy(klima, strat,polygon_sushi_router, mr, opts, publish_source=True)
strat = StratYieldRedirectAAVE.at(strat)
strat.setMasterChefRewarder(yd.address, opts)
strat.setKeeper(yd.address, opts)

mr = MultiRewards.deploy(acct.address, vault, opts)
oneHour = 3600
ydaddress='0x7FA4b39eb6e79152c76888ed4a97Fa716fD58A60'
mr.addReward(klima, ydaddress, oneHour)

yd.setRewarder(mr.address)




