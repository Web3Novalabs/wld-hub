// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract WLDHUBItems is ERC1155, Ownable, ERC1155Pausable, ERC1155Burnable, ERC1155Supply {
    /// @dev Thrown when an invalid (zero) address is provided.
    error InvalidAddress();

    /// @dev Thrown when array lengths do not match.
    error InvalidArrayLength();

    /// @notice Mapping to store individual URIs for each token ID.
    mapping(uint256 => string) private _tokenURIs;

    /// @notice Emitted when a token is minted.
    event TokenMinted(address indexed to, uint256 indexed id, uint256 amount);

    /// @notice Emitted when multiple tokens are minted in a batch.
    event TokenBatchMinted(address indexed to, uint256[] ids, uint256[] amounts);

    /**
     * @notice Initializes the contract and sets the owner.
     * @param initialOwner Address to be set as the initial contract owner.
     */
    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {
        if (initialOwner == address(0)) revert InvalidAddress();
    }

    /**
     * @notice Sets a custom URI for a given token ID.
     * @dev Only callable by the owner.
     * @param id Token ID to set the URI for.
     * @param newuri The new URI to assign to the token ID.
     */
    function setURI(uint256 id, string memory newuri) public onlyOwner {
        _tokenURIs[id] = newuri;
    }

    /**
     * @notice Returns the URI for a given token ID.
     * @param id Token ID to query.
     * @return The metadata URI for the token.
     */
    function uri(uint256 id) public view override returns (string memory) {
        return _tokenURIs[id];
    }

    /**
     * @notice Pauses all token transfers.
     * @dev Only callable by the owner.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses all token transfers.
     * @dev Only callable by the owner.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @notice Mints a specific amount of a token to a given address.
     * @dev Only callable by the owner.
     * @param account Address to mint the token to.
     * @param id Token ID to mint.
     * @param amount Amount of tokens to mint.
     * @param data Additional data passed to the receiver.
     */
    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyOwner {
        if (account == address(0)) revert InvalidAddress();
        _mint(account, id, amount, data);
        emit TokenMinted(account, id, amount);
    }

    /**
     * @notice Mints multiple token types in a batch to a given address.
     * @dev Only callable by the owner.
     * @param to Address to mint the tokens to.
     * @param ids List of token IDs to mint.
     * @param amounts Corresponding list of amounts to mint for each token ID.
     * @param data Additional data passed to the receiver.
     */
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        if (to == address(0)) revert InvalidAddress();
        if (ids.length != amounts.length) revert InvalidArrayLength();

        _mintBatch(to, ids, amounts, data);
        emit TokenBatchMinted(to, ids, amounts);
    }

    /**
     * @dev Internal hook called before any token transfer, mint, or burn.
     * @param from Address transferring from.
     * @param to Address transferring to.
     * @param ids List of token IDs being transferred.
     * @param values List of token amounts being transferred.
     */
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Pausable, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}
