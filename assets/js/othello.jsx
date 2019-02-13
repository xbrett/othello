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
     };
    this.channel = props.channel;

    this.channel
        .join()
        .receive("ok", this.updateView.bind(this))
        .receive("error", resp => { console.log("Unable to join", resp); });
  }

  updateView(view) {
    this.setState(view.game);
  }

  handleClick(tile) {

  }

  restart() {
    this.channel.push("new")
        .receive("ok", this.updateView.bind(this));
  }

  render() {
    return (
      <div className="othello">
        <h1>Othello</h1>
        <table className="board">
          <tbody>
            <RenderBoard root={this} tiles={this.state.tiles}/>
          </tbody>
        </table>
        <h4>Player 1: {this.state.score}</h4>
        <h4>Player 2: {this.state.score}</h4>
        <button type="button" onClick={this.restart.bind(this)}>Restart</button>
      </div>
    );
  }
}

function RenderBoard(props) {
  let { root, tiles } = props;
  let board = [];
  let width = 4;

  for (let i = 0; i < width; i++) {
    board.push(
      <tr key={i}>
        <RenderRow root={root} tiles={tiles.slice(i*width, i*width+4)} />
      </tr>
    );
  }
  return board;
}

function RenderRow(props) {
  let { root, tiles } = props;
  let row = [];

  for (let j = 0; j < tiles.length; j++) {
    if (tiles[j].visible) {
      row.push(
        <td key={tiles[j].key} onClick={() =>  root.handleClick(tiles[j])}>
          <div data-key={tiles[j].key} className="tile visible">{tiles[j].letter}</div>
        </td>
      );
    } else {
      row.push(
        <td key={tiles[j].key} onClick={() => { root.handleClick(tiles[j])}}>
          <div data-key={tiles[j].key} className="tile">{tiles[j].letter}</div>
        </td>
      );
    } 
  }
  return row;
}