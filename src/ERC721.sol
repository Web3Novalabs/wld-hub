// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// {
//   "name": "bear 2 the incredible liviong bear",
//   "description": "bear 2 the incredible liviong bear, this is an incredible one ",
//   "image": "ipfs://bafkreigq4li5emwa77ibch6ysqz5nfanx3lhpku4uv2xgq7sfsek5s7eya"
// }

contract QuickNodeNFT is ERC721URIStorage, Ownable {
    constructor() ERC721("QuickNode Sharks", "QNS") Ownable(msg.sender) {}

    function mint(
        address _to,
        uint256 _tokenId,
        string calldata _uri
    ) external onlyOwner {
        _mint(_to, _tokenId);
        _setTokenURI(_tokenId, _uri);
    }
}






// interface IERC721 {
//     function balanceOf(address owner) external view returns (uint256);
//     function ownerOf(uint256 tokenId) external view returns (address);
//     function safeTransferFrom(address from, address to, uint256 tokenId) external;
//     function transferFrom(address from, address to, uint256 tokenId) external;
//     function approve(address to, uint256 tokenId) external;
//     function getApproved(uint256 tokenId) external view returns (address);
//     function setApprovalForAll(address operator, bool approved) external;
//     function isApprovedForAll(address owner, address operator) external view returns (bool);
    
//     event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
//     event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
//     event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
// }

// interface IERC721Receiver {
//     function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
// }

// contract ERC721Token is IERC721 {
//     string public name;
//     string public symbol;
    
//     // Token ID to owner address
//     mapping(uint256 => address) private _owners;
//     // Owner address to token count
//     mapping(address => uint256) private _balances;
//     // Token ID to approved address
//     mapping(uint256 => address) private _tokenApprovals;
//     // Owner to operator approvals
//     mapping(address => mapping(address => bool)) private _operatorApprovals;
    
//     constructor(string memory tokenName, string memory tokenSymbol) {
//         name = tokenName;
//         symbol = tokenSymbol;
//     }
    
//     function balanceOf(address owner) public view override returns (uint256) {
//         require(owner != address(0), "ERC721: balance query for the zero address");
//         return _balances[owner];
//     }
    
//     function ownerOf(uint256 tokenId) public view override returns (address) {
//         address owner = _owners[tokenId];
//         require(owner != address(0), "ERC721: owner query for nonexistent token");
//         return owner;
//     }
    
//     function approve(address to, uint256 tokenId) public override {
//         address owner = ownerOf(tokenId);
//         require(to != owner, "ERC721: approval to current owner");
//         require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
//             "ERC721: approve caller is not owner nor approved for all");
            
//         _tokenApprovals[tokenId] = to;
//         emit Approval(owner, to, tokenId);
//     }
    
//     function getApproved(uint256 tokenId) public view override returns (address) {
//         require(_owners[tokenId] != address(0), "ERC721: approved query for nonexistent token");
//         return _tokenApprovals[tokenId];
//     }
    
//     function setApprovalForAll(address operator, bool approved) public override {
//         require(operator != msg.sender, "ERC721: approve to caller");
//         _operatorApprovals[msg.sender][operator] = approved;
//         emit ApprovalForAll(msg.sender, operator, approved);
//     }
    
//     function isApprovedForAll(address owner, address operator) public view override returns (bool) {
//         return _operatorApprovals[owner][operator];
//     }
    
//     function transferFrom(address from, address to, uint256 tokenId) public override {
//         require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
//         _transfer(from, to, tokenId);
//     }
    
//     function safeTransferFrom(address from, address to, uint256 tokenId) public override {
//         safeTransferFrom(from, to, tokenId, "");
//     }
    
//     function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
//         require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
//         _safeTransfer(from, to, tokenId, _data);
//     }
    
//     function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
//         _transfer(from, to, tokenId);
//         require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
//     }
    
//     function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
//         require(_owners[tokenId] != address(0), "ERC721: operator query for nonexistent token");
//         address owner = ownerOf(tokenId);
//         return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
//     }
    
//     function _transfer(address from, address to, uint256 tokenId) internal {
//         require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
//         require(to != address(0), "ERC721: transfer to the zero address");
        
//         // Clear approvals
//         _approve(address(0), tokenId);
        
//         _balances[from] -= 1;
//         _balances[to] += 1;
//         _owners[tokenId] = to;
        
//         emit Transfer(from, to, tokenId);
//     }
    
//     function _mint(address to, uint256 tokenId) internal {
//         require(to != address(0), "ERC721: mint to the zero address");
//         require(_owners[tokenId] == address(0), "ERC721: token already minted");
        
//         _balances[to] += 1;
//         _owners[tokenId] = to;
        
//         emit Transfer(address(0), to, tokenId);
//     }
    
//     function _approve(address to, uint256 tokenId) internal {
//         _tokenApprovals[tokenId] = to;
//     }
    
//     function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
//         if (isContract(to)) {
//             try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
//                 return retval == IERC721Receiver.onERC721Received.selector;
//             } catch (bytes memory reason) {
//                 if (reason.length == 0) {
//                     revert("ERC721: transfer to non ERC721Receiver implementer");
//                 } else {
//                     assembly {
//                         revert(add(32, reason), mload(reason))
//                     }
//                 }
//             }
//         } else {
//             return true;
//         }
//     }
    
//     function isContract(address account) internal view returns (bool) {
//         uint256 size;
//         assembly {
//             size := extcodesize(account)
//         }
//         return size > 0;
//     }
// }
