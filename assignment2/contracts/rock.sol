// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    address public owner;
    address public player1;
    address public player2;
    uint public betAmount;
    uint public player1Choice;
    uint public player2Choice;
    address public winner;

    enum Choices { None, Rock, Paper, Scissors }
    Choices constant defaultChoice = Choices.None;

    event GameResult(address player, Choices choice, string result);

    constructor() {
        owner = msg.sender;
        betAmount = 0.0001 ether;
    }

    function play(uint choice) public payable {
        require(msg.sender != owner, "Owner cannot play");
        require(msg.value == betAmount, "Incorrect bet amount");
        require(player1 == address(0) || player2 == address(0), "Game is full");
        require(player1 != msg.sender && player2 != msg.sender, "Cannot play twice");

        if (player1 == address(0)) {
            player1 = msg.sender;
            player1Choice = choice;
        } else {
            player2 = msg.sender;
            player2Choice = choice;
            resolveGame();
        }
    }

    function resolveGame() private {
        require(player1 != address(0) && player2 != address(0), "Game is not ready to resolve");

        if (player1Choice == player2Choice) {
            winner = address(0);
            emit GameResult(player1, Choices(player1Choice), "Draw");
            emit GameResult(player2, Choices(player2Choice), "Draw");
        } else if (
            (player1Choice == uint(Choices.Rock) && player2Choice == uint(Choices.Scissors)) ||
            (player1Choice == uint(Choices.Paper) && player2Choice == uint(Choices.Rock)) ||
            (player1Choice == uint(Choices.Scissors) && player2Choice == uint(Choices.Paper))
        ) {
            winner = player1;
            emit GameResult(player1, Choices(player1Choice), "Win");
            emit GameResult(player2, Choices(player2Choice), "Lose");
            payable(player1).transfer(2 * betAmount);
        } else {
            winner = player2;
            emit GameResult(player1, Choices(player1Choice), "Lose");
            emit GameResult(player2, Choices(player2Choice), "Win");
            payable(player2).transfer(2 * betAmount);
        }

        resetGame();
    }

    function resetGame() private {
        player1 = address(0);
        player2 = address(0);
        player1Choice = uint(defaultChoice);
        player2Choice = uint(defaultChoice);
    }
}
