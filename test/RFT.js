const RFT = artifacts.require('RFT.sol');
const NFT = artifacts.require('NFT.sol');
const DAI= artifacts.require('DAI.sol');
const { time } = require('@openzeppelin/test-helpers');


const DAI_AMOUNT = web3.utils.toWei('25000');
const SHARE_AMOUNT = web3.utils.toWei('25000');

contract ('RFT', async addresses => {                     //when we start the contract block for RFT we pass an async callback function with one built in argument (addresses from truffle) which is an array 
  const [admin, buyer1, buyer2, buyer3, buyer4, _] = addresses;

  it ('ICO should work', async ()=> {
    const dai = await DAI.new();                    //deploy dai and nft token 
    const nft = await NFT.new('My NFT', 'MNFT');    //nft needs a name and symbol to instantiate
    await nft.mint(admin, 1);                       //here we mint an NFT for the admin and the amount/tokenId will be 1. This simulates the admin buying an NFT from GhostMarket
    await Promise.all([                             //we mint dai for each of the buyers
      dai.mint(buyer1, DAI_AMOUNT),                // we use a Promise.all to run all the minting for each buyer we send an equal amount of DAI_AMOUNT to each buyer
      dai.mint(buyer2, DAI_AMOUNT),
      dai.mint(buyer3, DAI_AMOUNT),
      dai.mint(buyer4, DAI_AMOUNT)
    ]);


//now that we have the two mocks we can now deploy the RFT contract
//when we deploy RFT itself is an ERC20 and it has a constructor that needs a  string memory _name,string memory _symbol,address _nftAddress,uint _nftId,uint _icoSharePrice,uint _icoShareSupply,address _daiAddress
//the to is the nft.address and the amount is 1

    const rft = await RFT.new('MY awesome RFT','RFT', nft.address, 1, 1,web3.utils.toWei('100000'),dai.address);   
//now we need to call the startIco() which transfers the NFT from the admin to the RFT contract. 
//when we use transferFrom() it is a delegated transfer. in order to do this 1st you must approve another smart contract address to spend your token.
  await nft.approve(rft.address, 1);
  await rft.startIco()

  //next we have to approve the contract rft.address to spend the DAI_AMOUNT of the buyer 
  //so we approved the rft contract to spend the buyers ERC20 DAI tokens (RFT and DAI are ERC20) 
  //and we specify that buyer1 is actually investing in the ICO etc. for the other buyers
  await dai.approve(rft.address, DAI_AMOUNT, {from:buyer1});
  await rft.buyShare(SHARE_AMOUNT, {from:buyer1});
  await dai.approve(rft.address, DAI_AMOUNT, {from:buyer2});
  await rft.buyShare(SHARE_AMOUNT, {from:buyer2});
  await dai.approve(rft.address, DAI_AMOUNT, {from:buyer3});
  await rft.buyShare(SHARE_AMOUNT, {from:buyer3});
  await dai.approve(rft.address, DAI_AMOUNT, {from:buyer4});
  await rft.buyShare(SHARE_AMOUNT, {from:buyer4});
  //now force the ICO to end by using the time function before testing if all the token balances are correct
  await time.increase(7*86400+1);               //7days * 86400seconds
  //withdraw the profit and checkbalances
  await rft.withdrawProfits();
  const balanceShareBuyer1 = await rft.balanceOf(buyer1);
  const balanceShareBuyer2 = await rft.balanceOf(buyer2);
  const balanceShareBuyer3 = await rft.balanceOf(buyer3);
  const balanceShareBuyer4 = await rft.balanceOf(buyer4);
  assert(balanceShareBuyer1.toString()===SHARE_AMOUNT);
  assert(balanceShareBuyer2.toString()===SHARE_AMOUNT);
  assert(balanceShareBuyer3.toString()===SHARE_AMOUNT);
  assert(balanceShareBuyer4.toString()===SHARE_AMOUNT);
  //also check the admin balance
  const balanceAdminDai = await dai.balanceOf(admin);
  assert(balanceAdminDai.toString()===web3.utils.toWei('100000'));
  });
});



