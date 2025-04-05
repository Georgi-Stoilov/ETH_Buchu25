// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

interface IUniswapV2Router02 {
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

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
}

contract LiquidityAndSwap {
    IUniswapV2Router02 public uniswapRouter;

    // Set the Uniswap V2 router address upon deployment.
    constructor() {
        // Sepolia V2Router02 address
        uniswapRouter = IUniswapV2Router02(0xeE567Fe1712Faf6149d80dA1E6934E354124CfE3);
    }

    /**
     * @notice Adds liquidity to a Uniswap V2–like pool.
     */
    function addLiquidityTokens(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        uint deadline
    ) external {
        // Transfer tokens from user to contract.
        require(IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired), "Transfer tokenA failed");
        require(IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired), "Transfer tokenB failed");

        // Approve router to spend tokens.
        require(IERC20(tokenA).approve(address(uniswapRouter), amountADesired), "Approve tokenA failed");
        require(IERC20(tokenB).approve(address(uniswapRouter), amountBDesired), "Approve tokenB failed");

        // Call router to add liquidity.
        uniswapRouter.addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            msg.sender,
            deadline
        );
    }
    
    /**
     * @notice Swaps an exact amount of tokenIn for tokenOut.
     */
    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOutMin,
        uint deadline
    ) external {
        // Transfer the input tokens.
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "Transfer failed");
        // Approve router.
        require(IERC20(tokenIn).approve(address(uniswapRouter), amountIn), "Approve failed");

        // Create swap path array.
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;
        
        // Execute token swap.
        uniswapRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }
}
