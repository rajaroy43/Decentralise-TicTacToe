//SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

}
contract TicTacToe{
    using SafeMath for uint;
    uint8 public boardSize=3;
    address[3][3] public  board;
    address payable public player1;
    address payable public player2;
    address payable public activePlayer;
    uint8 public movesCounter;
    bool public isGameActive;
    uint public constant gameCost=0.1 ether;
    event playerJoined(address player);
    uint private balanceToWithDrawPlayer1;
    uint private balanceToWithDrawPlayer2;
    uint timeToReact=3 minutes;
    uint public gameValidTime;
    //constructor is for creating the game by user (player1 ) and now player2 have to join this game
    constructor() payable{
        player1=msg.sender;
        require(msg.value==0.1 ether,"please provide 0.1 ether to create this game");
        emit playerJoined(msg.sender);
        gameValidTime=block.timestamp.add(timeToReact);
    }
    event nextPlayerJoined(address player);
    event cantJoinTimeLeft();
    event nextPlayer(address player);
    function joinGame()public payable{
        require(player2==address(0),'no more player can join this game');
        require(msg.value==0.1 ether,"please provide 0.1 ether to join this game");
        //give money to contract creater
        player2=msg.sender;
        if(gameValidTime<block.timestamp){
            player2.transfer(msg.value);
            emit cantJoinTimeLeft();
            selfdestruct(player1);
            return;
        }
        //randomly activeplayer choosen
        if((block.number)%2==1)
        activePlayer=player2;
        else
        activePlayer=player1;
        emit nextPlayerJoined(msg.sender);
        isGameActive=true;
        gameValidTime=block.timestamp.add(timeToReact);
        emit nextPlayer(activePlayer);
    }
    event playedMove(uint8 row,uint8 column,address player);
    function playYourMove(uint8 x,uint8 y)public{
         uint8 i;
        //game must be in running state not draw or not winner or loose
        //checking by isGameActive
        assert(isGameActive);
        require((x<boardSize&&y<boardSize),"X or y cant be greater than boardSize");
        require((player1==msg.sender||player2==msg.sender),"Outsider can't play this game");
        require(gameValidTime>block.timestamp,"Time Out to play move");
        require(activePlayer==msg.sender,"Opposition player must play his move");
        require(board[x][y]==address(0),"You Can't play this move becoz this move is already played");
        board[x][y]=msg.sender;
        emit playedMove(x,y,msg.sender);
        movesCounter++;
        //for checking a player have continous row and continous column(3 times)

        //now check for column(1st whole column or 2nd whole column or 3rd whole column by user value of y)
        for(i=0;i<boardSize;i++)
        {
            if(board[i][y]!=activePlayer)
            {
            break;
        }
        else{
            //win
            if(i==boardSize-1){
                //winner
                setWinner(activePlayer);
                return;
            }
        }
        }
        //for every row
        for(i=0;i<boardSize;i++){
            if(board[x][i]!=activePlayer){
                break;
            }
            else{
                //win
                if(i==boardSize-1){
                    setWinner(activePlayer);
                    //winner
                    return;
                }
            }
        }

        //for diagonal

        //if our next move is for diagonal then x==y;
        if(x==y){
            for(i=0;i<boardSize;i++){
            if(board[i][i]!=activePlayer){
                break;
            }
            else{
                //win
                if(i==boardSize-1){
                    //winner
                    setWinner(activePlayer);
                    return;
                }
            }
        }
        }

        //for anti-diagonal

        if((x+y)==boardSize-1){
            for(i=0;i<boardSize;i++){
            if(board[i][boardSize-i-1]!=activePlayer){
                break;
            }
            else{
                //win
                if(i==boardSize-1){
                    //winner
                    setWinner(activePlayer);
                    return;
                }
            }
        }
        }
        //if all move havebeen played and no winner found then we have to draw this game
        if(movesCounter==boardSize**2){
            //draw game
            draw();
            return;
        }
        if(player1==activePlayer)
            activePlayer=player2;
        else
            activePlayer=player1;
        emit nextPlayer(activePlayer);
        gameValidTime=block.timestamp.add(timeToReact);
    }
    event gameOverWithWin(address winnerPlayer);
    event paymentSucess(address winnerPlayer,uint ammountWin);
    function setWinner(address payable player)private{
        isGameActive=false;
        uint balance=address(this).balance;
        //emit an event
        emit gameOverWithWin(player);
        //transfer money to winner if it's a money game
        //here i dont use transfer() because if transaction failed then it get back it previous state
        //let say player play his move at (0,0), (1,0) and last move (2,0) and he win if transaction failed
        //then it get back it previous state as 1,0 so we dont use here transfer
        //player.transfer(address(this).balance);
        //(bool success,  ) = player.call{value:balance}("");
        if(player.send(balance)!=true){
            //transaction failed any reason
            if(player==player1){
                balanceToWithDrawPlayer1=balance;
            }
            else{
                balanceToWithDrawPlayer2=balance;
            }
        }
        else{
            emit paymentSucess(player,balance);
        }
    }
    function forceWithDrawWin()public{
        if(msg.sender==player1){
            require(balanceToWithDrawPlayer1>0,"game winner already choosen or you are not a winner");
            balanceToWithDrawPlayer1=0;
            player1.transfer(balanceToWithDrawPlayer1);
            emit paymentSucess(player1,balanceToWithDrawPlayer1);
        }
        else{
            require(balanceToWithDrawPlayer2>0,'game winner already choosen or you are not a winner');
            balanceToWithDrawPlayer2=0;
            player2.transfer(balanceToWithDrawPlayer2);
            emit paymentSucess(player2,balanceToWithDrawPlayer2);
        }
    }
    event gameOverWithDraw();
    function draw()private{
        isGameActive=false;
        emit gameOverWithDraw();
        uint balanceToPayout=address(this).balance/2;
        if(player1.send(balanceToPayout)==false){
            balanceToWithDrawPlayer1=balanceToWithDrawPlayer1.add(balanceToPayout);
        }
        else{
            emit paymentSucess(player1,balanceToPayout);
        }
        if(player2.send(balanceToPayout)==false){
            balanceToWithDrawPlayer2=balanceToWithDrawPlayer2.add(balanceToPayout);
        }
        else{
            emit paymentSucess(player2,balanceToPayout);
        }
    }
    event pullEmergencyFundBack();
    function emergencyFundBack()public{
        require(gameValidTime<block.timestamp,"game is in running state and time valid ");
        draw();
        emit pullEmergencyFundBack();
    }
    function getBoard()public view returns(address[3][3] memory){
        return board;
    }
    function getContractBalance()public  view returns(uint){
        return address(this).balance;
    }
    //if anyone can't join in 3 minutes he will get refund back
    event refundBack(address gameCreator);
    function getRefundBack()public{
        require(msg.sender==player1,"You are not a player who create this game");
        require(block.timestamp>gameValidTime,"game is in running state and time valid ");
        require(player2==address(0),"you can click a function emergencyFundBack");
        player1.transfer(gameCost);
        emit refundBack(msg.sender);
    }
}
