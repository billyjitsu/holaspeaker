// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract HolaMetaversoSpeaker is ERC721A, Ownable{
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 200;
    uint256 public constant MAX_PUBLIC_MINT = 1;

    string private  baseTokenUri;
    string public   placeholderTokenUri;

    //deploy smart contract, toggle publicSale 
    bool public isRevealed;
    bool public pause;
    bool locked = false;

    mapping(address => uint256) public totalPublicMint;

    constructor() ERC721A("HolaMetaversoSpeaker", "HOLASPKR"){

    }

    //Make sure that calls are not from contracts
    modifier callerIsUser() {
        require(tx.origin == msg.sender, "Hola - Cannot be called by a contract");
        _;
    }

    function mint() external payable onlyOwner {
        require(!pause, "Hola - Not Yet Active.");
        require((totalSupply() + 1) <= MAX_SUPPLY, "Hola - Beyond Max Supply");
       // require((totalPublicMint[msg.sender] + 1) <= MAX_PUBLIC_MINT, "Hola - Already minted!");

        totalPublicMint[msg.sender] += 1;
        _safeMint(msg.sender, 1);
    }

    function mintFor(address _adr) external onlyOwner{
        totalPublicMint[_adr] += 1;
        _safeMint(_adr, 1);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenUri;
    }

    //return uri for certain token
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        uint256 trueId = tokenId + 1;

        if(!isRevealed){
            return placeholderTokenUri;
        }
  
        return bytes(baseTokenUri).length > 0 ? string(abi.encodePacked(baseTokenUri, trueId.toString(), ".json")) : "";
    }

    /// @dev walletOf() function shouldn't be called on-chain due to gas consumption
    function walletOf() external view returns(uint256[] memory){
        address _owner = msg.sender;
        uint256 numberOfOwnedNFT = balanceOf(_owner);
        uint256[] memory ownerIds = new uint256[](numberOfOwnedNFT);

        for(uint256 index = 0; index < numberOfOwnedNFT; index++){
            ownerIds[index] = tokenOfOwnerByIndex(_owner, index);
        }

        return ownerIds;
    }

    //Stop those speakers from having paperhands
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 tokenId,
        uint256 quantity
    ) internal virtual override {
        require(!locked, "Cannot transfer - currently locked");
    }

    // Lock Transfers
    function lockTransfers() external onlyOwner {
        locked = !locked;
    }

    //Only Owner Functions
    function setTokenUri(string memory _baseTokenUri) external onlyOwner{
        baseTokenUri = _baseTokenUri;
    }
    function setPlaceHolderUri(string memory _placeholderTokenUri) external onlyOwner{
        placeholderTokenUri = _placeholderTokenUri;
    }

    function togglePause() external onlyOwner{
        pause = !pause;
    }

    function toggleReveal() external onlyOwner{
        isRevealed = !isRevealed;
    }

    //function to pull out token
    function withdrawToken(IERC20 token) public onlyOwner {
        require(token.transfer(msg.sender, token.balanceOf(address(this))), "Unable to transfer");
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }


}