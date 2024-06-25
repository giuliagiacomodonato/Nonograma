import React from 'react';

function Square({ value, onClick }) {
    let  pintar = value === "#" ? "square filledSquare" : "square";
    return (
        <button className={"square"+pintar} onClick={onClick}>
            {value !== '_' ? value : null}
        </button>
    );
}

export default Square;