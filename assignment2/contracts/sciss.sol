// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    address public player1;
    address public player2;
    uint256 public betAmount = 100000000000000; // 0.0001 tBNB in wei
    uint256 public result;
    address public winner;
    address public owner;

    enum Move { None, Rock, Paper, Scissors }

    struct Player {
        Move move;
        bool revealed;
    }

    mapping(address => Player) public players;

    event GameResult(address player, uint256 result);

    constructor() {
        owner = msg.sender;
    }

    function play(Move move) public payable {
        require(player1 == address(0) || player2 == address(0), "Game is full");
        require(msg.value == betAmount, "Incorrect bet amount");
        require(players[msg.sender].move == Move.None, "You have already played");

        if (player1 == address(0)) {
            player1 = msg.sender;
        } else {
            player2 = msg.sender;
        }

        players[msg.sender] = Player(move, false);

        if (player1 != address(0) && player2 != address(0)) {
            determineWinner();
        }
    }

    function reveal(Move move) public {
        require(players[msg.sender].revealed == false, "You have already revealed your move");
        players[msg.sender].move = move;
        players[msg.sender].revealed = true;

        if (players[player1].revealed && players[player2].revealed) {
            determineWinner();
        }
    }

    function determineWinner() private {
        require(player1 != address(0) && player2 != address(0), "Two players are required to determine the winner");

        Move move1 = players[player1].move;
        Move move2 = players[player2].move;

        if (move1 == move2) {
            result = 0;
            winner = address(0); // It's a tie
        } else if ((move1 == Move.Rock && move2 == Move.Scissors) ||
                   (move1 == Move.Paper && move2 == Move.Rock) ||
                   (move1 == Move.Scissors && move2 == Move.Paper)) {
            result = 1;
            winner = player1;
        } else {
            result = 2;
            winner = player2;
        }

        emit GameResult(winner, result);
    }

    function withdraw() public {
        require(msg.sender == winner, "Only the winner can withdraw the reward");
        require(result > 0, "No result to withdraw");

        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Failed to send the reward");
        result = 0;
    }
}
