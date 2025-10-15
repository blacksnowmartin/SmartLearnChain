import React, { useEffect, useState, useCallback, useRef } from 'react';
// import { game_backend } from '../../../declarations/game_backend';
import '../SnakeGame.scss';

const GRID_SIZE = 30;
const INITIAL_SNAKE = [{ x: 5, y: 5 }];
const INITIAL_DIRECTION = 'Right';
const INITIAL_FOOD = { x: 10, y: 10 };
const INITIAL_OBSTACLES = [
    { x: 2, y: 2 }, { x: 2, y: 3 }, 
  { x: 3, y: 2 }, { x: 4, y: 2 }, { x: 5, y: 2 },
  { x: 15, y: 15 }, { x: 20, y: 20 }
];
const MOVE_DELAY = 100;
const OPPOSITE_DIRECTIONS = {
  Up: 'Down',
  Down: 'Up',
  Left: 'Right',
  Right: 'Left'
};

const SnakeGame = () => {
  const [snake, setSnake] = useState(INITIAL_SNAKE);
  const [direction, setDirection] = useState(INITIAL_DIRECTION);
  const [food, setFood] = useState(INITIAL_FOOD);
  const [obstacles] = useState(INITIAL_OBSTACLES);
  const [score, setScore] = useState(0);
  const [gameOver, setGameOver] = useState(false);
  const [loading, setLoading] = useState(false);
  const gameLoopRef = useRef(null);
  const nextDirectionRef = useRef(null);

  // Generate random food position
  const generateFood = useCallback(() => {
    let newFood;
    do {
      newFood = {
        x: Math.floor(Math.random() * GRID_SIZE),
        y: Math.floor(Math.random() * GRID_SIZE)
      };
    } while (
      snake.some(segment => segment.x === newFood.x && segment.y === newFood.y) ||
      obstacles.some(obs => obs.x === newFood.x && obs.y === newFood.y)
    );
    return newFood;
  }, [snake, obstacles]);

  // Initialize or reset game
  const initializeGame = useCallback(async () => {
    setLoading(true);
    try {
      setSnake(INITIAL_SNAKE);
      setDirection(INITIAL_DIRECTION);
      setFood(INITIAL_FOOD);
      setScore(0);
      setGameOver(false);
      nextDirectionRef.current = null;
    } catch (err) {
      console.error('Initialization error:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  // Game loop
  useEffect(() => {
    if (gameOver || loading) return;

    const moveSnake = () => {
      if (nextDirectionRef.current && nextDirectionRef.current !== OPPOSITE_DIRECTIONS[direction]) {
        setDirection(nextDirectionRef.current);
        nextDirectionRef.current = null;
      }

      const head = snake[0];
      let newHead;
      switch (direction) {
        case 'Up': newHead = { x: head.x, y: head.y - 1 }; break;
        case 'Down': newHead = { x: head.x, y: head.y + 1 }; break;
        case 'Left': newHead = { x: head.x - 1, y: head.y }; break;
        case 'Right': newHead = { x: head.x + 1, y: head.y }; break;
        default: newHead = head;
      }

      // Check collisions
      if (newHead.x < 0 || newHead.x >= GRID_SIZE || newHead.y < 0 || newHead.y >= GRID_SIZE ||
          snake.some(segment => segment.x === newHead.x && segment.y === newHead.y) ||
          obstacles.some(obs => obs.x === newHead.x && obs.y === newHead.y)) {
        setGameOver(true);
        return;
      }

      let newSnake = [newHead, ...snake];

      // Check food
      if (newHead.x === food.x && newHead.y === food.y) {
        setScore(prev => prev + 1);
        setFood(generateFood());
      } else {
        newSnake.pop();
      }

      setSnake(newSnake);
    };

    gameLoopRef.current = setInterval(moveSnake, MOVE_DELAY);
    return () => clearInterval(gameLoopRef.current);
  }, [snake, direction, food, obstacles, gameOver, loading, generateFood]);

  // Keyboard controls
  useEffect(() => {
    const handleKeyPress = (e) => {
      if (gameOver || loading) return;

      let newDir;
      switch (e.key) {
        case 'ArrowUp': newDir = 'Up'; break;
        case 'ArrowDown': newDir = 'Down'; break;
        case 'ArrowLeft': newDir = 'Left'; break;
        case 'ArrowRight': newDir = 'Right'; break;
        case 'r':
        case 'R':
          initializeGame();
          return;
        default: return;
      }

      if (newDir !== direction && newDir !== OPPOSITE_DIRECTIONS[direction]) {
        nextDirectionRef.current = newDir;
      }
    };

    window.addEventListener('keydown', handleKeyPress);
    return () => window.removeEventListener('keydown', handleKeyPress);
  }, [direction, gameOver, loading, initializeGame]);

  // Mobile controls
  const simulateKeyPress = (key) => {
    window.dispatchEvent(new KeyboardEvent('keydown', { key }));
  };

  useEffect(() => {
    initializeGame();
  }, [initializeGame]);

  if (loading) {
    return <div className="game-container">Loading...</div>;
  }

  return (
    <div className="game-container">
      <div className="game-header">
        <h1>🐍 Snake Game</h1> {/* Changed from "Infinity Snake" to "Snake Game" */}
        <div className="score-board">
          <span>Score: {score}</span>
        </div>
      </div>

      <div className="game-grid">
        {Array.from({ length: GRID_SIZE }, (_, y) =>
          Array.from({ length: GRID_SIZE }, (_, x) => {
            const isSnake = snake.some(s => s.x === x && s.y === y);
            const isHead = snake[0]?.x === x && snake[0]?.y === y;
            const isFood = food.x === x && food.y === y;
            const isObstacle = obstacles.some(o => o.x === x && o.y === y);

            let cellClass = 'empty';
            if (isHead) cellClass = 'snake-head';
            else if (isSnake) cellClass = 'snake-body';
            else if (isFood) cellClass = 'food';
            else if (isObstacle) cellClass = 'obstacle';

            return <div key={`${x}-${y}`} className={`grid-cell ${cellClass}`} />;
          })
        )}
      </div>

      {gameOver && (
        <div className="game-over-overlay">
          <h2>Game Over!</h2>
          <p>Score: {score}</p>
          <button onClick={initializeGame}>Play Again</button>
        </div>
      )}

      <div className="mobile-controls">
        <button onClick={() => simulateKeyPress('ArrowUp')}>↑</button>
        <button onClick={() => simulateKeyPress('ArrowLeft')}>←</button>
        <button onClick={() => simulateKeyPress('ArrowDown')}>↓</button>
        <button onClick={() => simulateKeyPress('ArrowRight')}>→</button>
      </div>
    </div>
  );
};

export default SnakeGame;