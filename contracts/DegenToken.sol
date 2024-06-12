// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {
    struct Item {
        string name;
        uint256 price;
    }

    Item[] items;

    mapping(address => mapping(uint256 => bool)) internal redeemedItems;

    constructor() ERC20("DegenToken", "DGN") Ownable(msg.sender) {
        _mint(msg.sender, 700);
        autoAddItems();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function addItem(string memory name, uint256 price) public onlyOwner {
        items.push(Item(name, price));
    }

    function autoAddItems() internal onlyOwner {
        Item[] memory predefinedItems = new Item[](6);
        predefinedItems[0] = Item("Sword", 100);
        predefinedItems[1] = Item("Shield", 150);
        predefinedItems[2] = Item("Potion", 50);
        predefinedItems[3] = Item("Helmet", 120);
        predefinedItems[4] = Item("Armor", 200);
        predefinedItems[5] = Item("Boots", 80);

        for (uint256 i = 0; i < predefinedItems.length; i++) {
            items.push(predefinedItems[i]);
        }
    }

    function redeemTokens(uint256 itemId) public {
        require(itemId < items.length, "Invalid item ID");
        Item memory item = items[itemId];
        require(balanceOf(msg.sender) >= item.price, "Not enough tokens");
        require(!redeemedItems[msg.sender][itemId], "Item already redeemed");

        _burn(msg.sender, item.price);
        redeemedItems[msg.sender][itemId] = true;
    }

    function getItems() public view returns (Item[] memory) {
        return items;
    }

    function getMyItems() public view returns (Item[] memory){
        uint256 itemCount = items.length;
        uint256 redeemedCount = 0;

        for (uint256 i = 0; i < itemCount; i++) {
            if (redeemedItems[msg.sender][i]) {
                redeemedCount++;
            }
        }

        Item[] memory userItems = new Item[](redeemedCount);
        uint256 index = 0;

        for (uint256 i = 0; i < itemCount; i++) {
            if (redeemedItems[msg.sender][i]) {
                userItems[index] = items[i];
                index++;
            }
        }

        return userItems;
    }
}
