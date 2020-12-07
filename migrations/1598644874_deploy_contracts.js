const TicTacToe = artifacts.require("TicTacToe");
// const Web3= require('Web3');
// const provider=new Web3.providers.HttpProvider("http://localhost:9545");
// const web3=new Web3(provider);
// let accounts;
// const c=async()=>{
// accounts=await web3.eth.getAccounts();
// console.log(accounts[1])
// }
// c();
module.exports = function(_deployer) {
  // Use deployer to state migration tasks.
  //  _deployer.deploy(TicTacToe,{accounts:accounts,value:100000000000000000});
};
