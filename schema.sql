CREATE TABLE teams (
    id serial PRIMARY KEY,
    name VARCHAR(400) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    point_person VARCHAR(600) NOT NULL,
    point_person_email VARCHAR(1000) NOT NULL
);


CREATE TABLE volunteers (
    id serial PRIMARY KEY,
    name VARCHAR(400) NOT NULL,
    email VARCHAR(1000) NOT NULL
);

CREATE TABLE volunteer_teams (
    volunteer_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    suggestion VARCHAR(2000)
);
