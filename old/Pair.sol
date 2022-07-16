// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

pragma solidity ^0.8.0;

contract UniswapInteract{
    IERC20 private ERC20Token;
    IUniswapV2Factory private factory;
    IUniswapV2Router02 private router;
    IUniswapV2Pair private v2Pair;
    address private pair;
    address private tokenERC;
    address private Weth;
    uint256 public liquidity;
    uint256 public removedETH;
    uint256 [] public  amounts;

    constructor(address token){
        tokenERC = token;
      ERC20Token=  IERC20(tokenERC);
      router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
      Weth = router.WETH();
      factory = IUniswapV2Factory(router.factory());
      pair = factory.createPair(Weth, address(ERC20Token));
    }

    function addLiquidity( uint256 tokenAmount) public payable {
        IERC20(tokenERC).transferFrom(msg.sender,address(this),tokenAmount);
        IERC20(tokenERC).approve(address(router),tokenAmount);
        (,,liquidity)=router.addLiquidityETH{value:msg.value}(tokenERC,tokenAmount,0,0,msg.sender,block.timestamp);
        v2Pair=IUniswapV2Pair(pair);
    }
    function removeLiquidity(uint256 _liquidity) public {
        IUniswapV2Pair(pair).transferFrom(msg.sender,address(this),_liquidity);
        IUniswapV2Pair(pair).approve(address(router),liquidity);
        (,removedETH)=router.removeLiquidityETH(tokenERC,_liquidity,0,0,msg.sender,block.timestamp);
    }
    function swapTokenToETH( uint256 amountToSwap) public {
        IERC20(tokenERC).transferFrom(msg.sender,address(this),amountToSwap);
        IERC20(tokenERC).approve(address(router),amountToSwap);
        address[] memory pathForPair;
        pathForPair = new address[](2);
        pathForPair [0] = tokenERC;
        pathForPair [1] = Weth;
        (amounts) = router.swapExactTokensForETH(amountToSwap,0,pathForPair,msg.sender,block.timestamp);
    }
    function getPair() public view returns(address){
        return pair;
    }
}