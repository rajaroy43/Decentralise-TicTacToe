const TicTacToe = artifacts.require("TicTacToe");

contract('deploys a contract',async(accounts)=>{
  let instance;
  const player1=accounts[0];
  const player2=accounts[1];
  beforeEach(async ()=>{
    instance=await TicTacToe.new({from:player1,value:web3.utils.toWei('0.1','ether')});
 });

  it("Should have an empty board at begining",async()=>{
    const balance=await instance.getContractBalance();
    assert.equal(balance,web3.utils.toWei('0.1','ether'),"balance not equal");
    const board=await instance.getBoard();
    assert.equal(board[0][0],0);
  });

  it('Join game and Game winning',async()=>{
    let txResult=await instance.joinGame({from:player2,value:web3.utils.toWei('0.1','ether')});
    const balance=await instance.getContractBalance();
    assert.equal(balance,web3.utils.toWei('0.2','ether'),"balance not equal");
    // console.log(txResult.logs);
    txResult=await instance.playYourMove(0,0,{from:txResult.logs[1].args.player});
    txResult=await instance.playYourMove(0,1,{from:txResult.logs[1].args.player});
    txResult=await instance.playYourMove(1,0,{from:txResult.logs[1].args.player});
    txResult=await instance.playYourMove(1,1,{from:txResult.logs[1].args.player});
    txResult=await instance.playYourMove(2,0,{from:txResult.logs[1].args.player});
    const newContractBalance=await instance.getContractBalance();
    //now new ContractBalance must be 0 after winning or draw
    assert.equal(newContractBalance,0);
});
});
