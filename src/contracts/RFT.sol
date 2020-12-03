import '@openzeppelin/contracts/token/ERC721/IERC721.sol';   //allows us to man ipulate our NFT token
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';      //allows us to manipulate our DAI token
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';      //allows us to manipulate our Fungible Token and our DAI token

contract RFT is ERC20 {                              //we inherit the functionality of the ERC20
  uint public icoSharePrice;                                 //the ICO variables represent the point where people buy a share of our refungible token
  uint public icoShareSupply;                                 //they will pay for a share of our RFT with DAI and we need to set the price and total supply
  uint public icoEnd;                                         //this variable repesents the end of the ICO in time
  
  //these variables represent the NFT and DAi
  uint public nftId;                                         //when you manipulate an NFT you need to specify its ID in the SC of the NFT. A single NFT SC has several NFTs and you need to identify it.
  IERC721 public nft;                                        //we need a pointer to the NFT token that we will manipulate
  IERC20 public dai;                                        //we also need a pointer to DAI

  address public admin;                                   // this is the person who buys the NFT token and send it to the fungible RFT
  
  constructor(                                        //we set our constructor to pass all these arguments about the NFT  and the address of Dai
    string memory _name,
    string memory _symbol,
    address _nftAddress,
    uint _nftId,
    uint _icoSharePrice,
    uint _icoShareSupply,
    address _daiAddress
  ) public
  ERC20(_name, _symbol) {                             //we also instantiate the constructor of the ERC20 token and we need to pass it the _name and _symbol of the RFT
    nftId=_nftId;
    nft = IERC721(_nftAddress);                        //and inside the constructor we initialize the variables
    icoSharePrice=_icoSharePrice;
    icoShareSupply=_icoShareSupply;
    dai = IERC20(_daiAddress);
    admin=msg.sender;                                   //now the NFT is in our contract
  }
  function startIco() external {                          //this function allows us to start our ico
    require(msg.sender==admin, 'only admin');
    nft.transferFrom(msg.sender, address(this), nftId);   // transfers the NFT from the admin to the RFT contract
    icoEnd=block.timestamp + 7 * 86400;                   //we calculate the day ythe ICO ends so we use the current timestamp and add the number of seconds in one week.
  }
  function buyShare(uint shareAmount) external {          //this function is to buy a share of our contract. and we need to pass the amount of shares we wish to buy as the argument. 
    require(icoEnd>0, 'ICO not started yet');              // we want to make sure the ICO isnt finished yet
    require(block.timestamp <=icoEnd, 'ICO is finished');   //we want the current timestamp to be less than the value of icoEnd which is one week from the start.
    require(totalSupply()+ shareAmount<=icoShareSupply, 'not enough shares left');  //we want to make sure that we still have some shares available the total amount of shares issued can be got with totalSupply(an ERC20 function we inherited)
    uint daiAmount = shareAmount*icoSharePrice;         //this is the amount of DAI token paid by the buyer
    dai.transferFrom(msg.sender, address(this), daiAmount);  //transfer daiAmount from the sender to this contract
    _mint(msg.sender, shareAmount);                         //we issue the share by using _mint() of ERC20 we mint the share and send it to the msg.sender of the tx
  }
  function withdrawProfits() external {                   //the admin calls this function to withdraw the DAI that was sent to the contract. plus any remaining shares that were not bought
    require(msg.sender==admin, 'only admin');             //make sure the only person who can call this function is the admin
    require(block.timestamp > icoEnd, 'ICO not finished yet'); //make sure the ICO is over
    uint daiBalance=dai.balanceOf(address(this));         //in order to send the DAI token to the admin we first must calculate the daiBalance
    if(daiBalance>0){                                     //if there is any dai in our balance we transfer it to the admin. 
      dai.transfer(admin, daiBalance);
    }
    uint unsoldShareBalance = icoShareSupply-totalSupply();
    if(unsoldShareBalance>0){
      _mint(admin, unsoldShareBalance);       //to send the unsold shares back to the admin we mint them over
    }
  }
}