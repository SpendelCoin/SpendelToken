// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpendelToken is ERC20, Ownable {
    uint256 public maxWalletPercent = 1; // 1%
    uint256 public launchTime;
    bool public tradingOpen = false;

    mapping(address => bool) private _isExcludedFromLimit;

    constructor() ERC20("Spendel", "SPNDL") Ownable(msg.sender) {
        _mint(msg.sender, 8888888888 * 10 ** decimals());
        _isExcludedFromLimit[msg.sender] = true;
    }

    function openTrading() external onlyOwner {
        tradingOpen = true;
        launchTime = block.timestamp;
    }

    function setMaxWalletPercent(uint256 percent) external onlyOwner {
        require(percent >= 1, "Too small");
        maxWalletPercent = percent;
    }

    function excludeFromLimit(address account, bool excluded) external onlyOwner {
        _isExcludedFromLimit[account] = excluded;
    }

    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);

        if (from == address(0) || _isExcludedFromLimit[to]) return;

        if (tradingOpen && block.timestamp < launchTime + 1 hours) {
            uint256 maxTokens = (totalSupply() * maxWalletPercent) / 100;
            require(balanceOf(to) + value <= maxTokens, "Exceeds max wallet limit");
        }
    }
}