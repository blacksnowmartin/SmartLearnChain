import Array "mo:base/Array";
import Time "mo:base/Time";
import Int "mo:base/Int";
persistent actor {
 var pendingDirection : ?Direction = null;

 type Direction = { #Up; #Down; #Left; #Right };
  type Position = { x : Int; y : Int };
  type GameState = {
    snake : [Position];
    direction : Direction;
    food : Position;
    obstacles : [Position];
    score : Int;
    gameOver : Bool;
  };

  var gameState : GameState = {
    snake = [{ x = 5; y = 5 }];
    direction = #Right;
    food = { x = 10; y = 10 };
    obstacles = [{ x = 15; y = 15 }, { x = 20; y = 20 }];
    score = 0;
    gameOver = false;
  };

  // Update the snake's direction
  public shared func changeDirection(newDirection : Direction) : async () {
    if (not gameState.gameOver) {
      // gameState := { gameState with direction = newDirection };
      pendingDirection := ?newDirection;
    };
  };

  // Move the snake

  public shared func move() : async GameState {
  if (gameState.gameOver) {
    return gameState;
  };
  
 switch (pendingDirection) {
    case (?dir) {
      gameState := { gameState with direction = dir };
      pendingDirection := null;
    };
    case (null) {};
  };



  let head = gameState.snake[0];
  let newHead : Position = switch (gameState.direction) {
    case (#Up) { { x = head.x; y = head.y - 1 } };
    case (#Down) { { x = head.x; y = head.y + 1 } };
    case (#Left) { { x = head.x - 1; y = head.y } };
    case (#Right) { { x = head.x + 1; y = head.y } };
  };

  // Check for collisions
  if (newHead.x < 0 or newHead.x >= 30 or newHead.y < 0 or newHead.y >= 30) {
    gameState := { gameState with gameOver = true };
    return gameState;
  };

  if (Array.find<Position>(gameState.snake, func(p) { p.x == newHead.x and p.y == newHead.y }) != null) {
    gameState := { gameState with gameOver = true };
    return gameState;
  };

  if (Array.find<Position>(gameState.obstacles, func(p) { p.x == newHead.x and p.y == newHead.y }) != null) {
    gameState := { gameState with gameOver = true };
    return gameState;
  };

  // Check if food is eaten
  var newSnake : [Position] = [];
  var newFood =  gameState.food;
  var newScore = gameState.score;
    // Generate new food
     if (newHead.x == gameState.food.x and newHead.y == gameState.food.y) {
    // Snake eats food - grow by keeping tail
    newSnake := Array.append([newHead], gameState.snake);
    newFood := { x = Int.abs(Time.now() % 30); y = Int.abs(Time.now() % 30) };
    newScore := gameState.score + 1;
  } else {
    // Move normally - remove tail
    newSnake := Array.append([newHead], Array.tabulate<Position>(
      gameState.snake.size() - 1,
      func(i) { gameState.snake[i] }
    ));
  };

  gameState := { 
    gameState with 
    snake = newSnake;
    food = newFood;
    score = newScore;
  };
  return gameState;
};


  // Reset the game
  public shared func reset() : async GameState {
    gameState := {
      snake = [{ x = 5; y = 5 }];
      direction = #Right;
      food = { x = 10; y = 10 };
      obstacles = [{ x = 15; y = 15 }, { x = 20; y = 20 }];
      score = 0;
      gameOver = false;
    };
    return gameState;
  };

};

