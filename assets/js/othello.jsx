import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'lodash';

export default function game_init(root, channel) {
    ReactDOM.render(<Othello channel={channel}/>, root);


}

class Othello extends React.Component {
  constructor(props) {
    super(props);
    this.state = { 
      board: [],
      turn: "balck",
      player1: "",
      player2: "",
      status: "waiting"
    };
    this.channel = props.channel;

    this.channel.join()
      .receive("ok", this.updateView.bind(this))
      .receive("ok", resp => { console.log("Success", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
  
    this.channel.on("update", view => this.updateView(view));
  }

  updateView(view, status) {
    console.log("View updated: " + view.game);
    this.setState(view.game);
  }

  gameOver(view, status) {
    this.channel.leave();
    this.updateView(view, status);
  }

  handleClick(tile) {

    if (tile.empty == true) {
      this.channel.push("click", {id: tile.id})
        .receive("ok", this.updateView.bind(this));
    } else {
      return;
    }
  }

  restart() {
    this.channel.push("restart")
        .receive("ok", this.updateView.bind(this));
  }

  getGameHeader() {
    // switch(this.game.status) {
    //   case "waiting":
    //     return "Waiting for another player to join";
    //   case "playing":
    //     if (this.state.turn == "black") {
    //         return "Black's turn";
    //     } else {
    //       return "White's Turn";
    //     }
    //   case "finished":
    //     if (blackScore < whiteScore) {
    //         if (this.state.player == "white") {
    //         return "You won!";
    //         }
    //         return "Player 2 won!";
    //     } else if (blackScore > whiteScore) {
    //         if (this.state.player == "black") {
    //         return "You won!";
    //         }
    //         return "Player 1 won!";
    //     } else {
    //         return "Tie";
    //     }
    //   case "player_left":
    //     return "Opponent has left the game.";
    // }   
  }

  render() {
    return (
      <div className="othello">
        <h1>Othello</h1>
        <h3>Status: {this.state.status}</h3>
        <table className="board">
          <tbody>
           <RenderBoard root={this} tiles={this.state.board}/> 
          </tbody>
        </table>
        <h4>Player 1: {this.state.player1}</h4>
        <h4>Player 2: {this.state.player2}</h4>
        <button type="button" onClick={this.restart.bind(this)}>Restart</button>
      </div>
    );
  }
}

function RenderBoard(props) {
  let { root, tiles } = props;
  let board = [];
  let width = 8;

  for (let i = 0; i < width; i++) {
    board.push(
      <tr key={i}>
        <RenderRow root={root} tiles={tiles.slice(i*width, i*width+width)} />
      </tr>
    );
  }
  return board;
}

function RenderRow(props) {
  let { root, tiles } = props;
  let row = [];

  for (let j = 0; j < tiles.length; j++) {
    if (tiles[j].empty == true) {
      row.push(
        <td key={tiles[j].id} onClick={() =>  root.handleClick(tiles[j])}>
          <div data-key={tiles[j].id} className="tile">{}</div>
        </td>
      );
    } else {
      row.push(
        <td key={tiles[j].id} onClick={() => { root.handleClick(tiles[j])}}>
          <div data-key={tiles[j].id} className={"tile " + tiles[j].color}>{}</div>
        </td>
      );
    } 
  }
  return row;
}