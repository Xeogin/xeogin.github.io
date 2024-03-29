[
CREATE TABLE IF NOT EXISTS cp_players (
	id INTEGER PRIMARY KEY { [mysql] AUTO_INCREMENT },
	auth VARCHAR(32) NOT NULL UNIQUE
);
]

[
CREATE TABLE IF NOT EXISTS cp_maps (
	id INTEGER PRIMARY KEY { [mysql] AUTO_INCREMENT },
	name VARCHAR(128) NOT NULL UNIQUE
);
]

[
CREATE TABLE IF NOT EXISTS cp_checkpoints (
	id INTEGER PRIMARY KEY { [mysql] AUTO_INCREMENT },
	player INTEGER REFERENCES cp_players(id) ON UPDATE CASCADE ON DELETE CASCADE,
	map INTEGER REFERENCES cp_maps(id) ON UPDATE CASCADE ON DELETE CASCADE,
	cp_index INTEGER NOT NULL,
	origin_x NUMERIC NOT NULL DEFAULT 0,
	origin_y NUMERIC NOT NULL DEFAULT 0,
	origin_z NUMERIC NOT NULL DEFAULT 0,
	angle_pitch NUMERIC NOT NULL DEFAULT 0,
	angle_yaw NUMERIC NOT NULL DEFAULT 0,
	angle_roll NUMERIC NOT NULL DEFAULT 0,
	velocity_x NUMERIC NOT NULL DEFAULT 0,
	velocity_y NUMERIC NOT NULL DEFAULT 0,
	velocity_z NUMERIC NOT NULL DEFAULT 0,
	UNIQUE(player, map, cp_index)
);
]
