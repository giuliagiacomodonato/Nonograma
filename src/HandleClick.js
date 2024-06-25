import React from 'react';

class HandleClick extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      isXSelected: false,
      isPaintSelected: true
    };
  }

  handleXClick = () => {
    this.setState({ isXSelected: true, isPaintSelected: false });
    
    this.props.selectX();
  };

  handlePaintClick = () => {
    this.setState({ isXSelected: false, isPaintSelected: true });
  
    this.props.selectPaint();
  };

  render() {
    return (
      <div>
        <button
          className={`X ${this.state.isXSelected ? 'selected' : ''}`}
          onClick={this.handleXClick}
          style={{ backgroundColor: this.state.isXSelected ? '#ffffff' : 'transparent' }}
        >
          X
        </button>

        <button
          className={`Paint ${this.state.isPaintSelected ? 'selected' : ''}`}
          onClick={this.handlePaintClick}
          style={{ backgroundColor: this.state.isPaintSelected ? '#000000' : 'transparent' }}
        >
          #
        </button>
      </div>
    );
  }
}

export default HandleClick;
