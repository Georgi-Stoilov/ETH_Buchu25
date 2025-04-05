// SPDX-License-Identifier: MIT
// (c)2024 Atlas (atlas@vialabs.io)

//import the uniswap library to swap in between chains
//uniswap has sdk package for that and it has to be used
pragma solidity ^0.8.29;

import "@vialabs-io/npm-contracts/MessageClient.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

// Minimal Uniswap V2 Router interface
interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract MyERC20 is ERC20Burnable, MessageClient {
    // Events for tracking cross-chain transfers
    event TokensBridged(address indexed sender, uint indexed destChainId, address indexed recipient, uint amount);
    event TokensReceived(uint indexed sourceChainId, address indexed recipient, uint amount);

    constructor() ERC20("Cross Chain Native Token", "CCNT") {
        MESSAGE_OWNER = msg.sender;
        _mint(msg.sender, 1_000_000 ether);
    }

    // New helper to simulate the active chain check
    function isActiveChain(uint _destChainId) internal view returns (bool) {
        // For demonstration, return true if the destination chain
        // is different from the current chain.
        return _destChainId != block.chainid;
    }

    function bridge(uint _destChainId, address _recipient, uint _amount) external {
        // If bridging from avalanche (43113) to base (84532), bypass active chain check.
        if (!(block.chainid == 43113 && _destChainId == 84532)) {
            require(isActiveChain(_destChainId), "Destination chain not active");
        }
        
        _burn(msg.sender, _amount);
        _sendMessage(_destChainId, abi.encode(_recipient, _amount));
        
        emit TokensBridged(msg.sender, _destChainId, _recipient, _amount);
    }

    function _processMessage(uint _sourceChainId, uint, bytes calldata _data) internal virtual override {
        (address _recipient, uint _amount) = abi.decode(_data, (address, uint));
        _mint(_recipient, _amount);
        
        // Emit event when tokens are received
        emit TokensReceived(_sourceChainId, _recipient, _amount);
    }

    // Swap tokens on Uniswap
    // Allows a user to swap a specified amount of this token for another token via Uniswap
    function swapTokensOnUniswap(
        address routerAddress,
        uint amountIn,
        uint amountOutMin,
        address tokenOut,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(balanceOf(msg.sender) >= amountIn, "Insufficient balance");
        // Transfer tokens from caller to this contract for swap
        _transfer(msg.sender, address(this), amountIn);
        // Approve router to spend tokens from this contract
        _approve(address(this), routerAddress, amountIn);
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = tokenOut;
        amounts = router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }
}
