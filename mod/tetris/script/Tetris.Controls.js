Tetris.Controls = function(clock, storage, board) {	this.clock = clock;	this.storage = storage;	this.board = board;	this.buttons = {		up : 87,		down : 83,		left : 65,		right : 68,		action : 32	};		this.clock.addTickListener(this);};//variablesTetris.Controls.prototype.clock = undefined;Tetris.Controls.prototype.storage = undefined;Tetris.Controls.prototype.board = undefined;Tetris.Controls.prototype.buttons = undefined;Tetris.Controls.prototype.currentShape = undefined;Tetris.Controls.prototype.gravityTimer = 0;Tetris.Controls.prototype.inputTimer = 0;Tetris.Controls.prototype.rotateTimer = 0;//methodsTetris.Controls.prototype.clearShape = function() {	if (this.currentShape) {		this.currentShape.destroy();		this.currentShape = undefined;	}};Tetris.Controls.prototype.tick = function(keysPressed) {	if (!this.currentShape) {		this.currentShape = this.storage.getShape();		this.currentShape.setParent(this.board.dom.root);		if (this.board.canMoveShape(this.currentShape, new Tetris.Pos(0, 0))) {					} else {			alert("GAME OVER!");			this.destroy();		}							}	if (keysPressed[this.buttons.action] === 0) {		this.rotateTimer = 0;	}	if (keysPressed[this.buttons.left] === 0 || keysPressed[this.buttons.right] === 0) {		this.inputTimer = 0;	}	var pos = new Tetris.Pos(0, 0);	if (this.rotateTimer) {		this.rotateTimer--;	} else {		if (keysPressed[this.buttons.action]) {			this.rotateTimer = 8;			do {				this.currentShape.rotate(true);			} while(!this.board.canMoveShape(this.currentShape, pos));		}	}	if (this.inputTimer) {		this.inputTimer--;	} else {				if (keysPressed[this.buttons.left]) {			pos.x--;			this.inputTimer = 3;		}		if (keysPressed[this.buttons.right]) {			pos.x++;			this.inputTimer = 3;		}			}			if (keysPressed[this.buttons.down]) {		pos.y++;	}	if (this.gravityTimer) {		this.gravityTimer--;	} else {		this.gravityTimer = 10;		pos.y++;	}		if (pos.x || pos.y) {		if (this.board.canMoveShape(this.currentShape, pos)) {			if (this.board.doMoveShape(this.currentShape, pos)) {				//collision				this.board.placeShape(this.currentShape);				this.clearShape();			} else {				//no collision			}		}	}};Tetris.Controls.prototype.destroy = function(pos) {	this.clock.removeTickListener(this);};