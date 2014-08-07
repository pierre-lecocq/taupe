--
-- -- Schema
--

CREATE TABLE member
(
    member_id serial NOT NULL PRIMARY KEY,
    username text NOT NULL,
    state int NOT NULL default 1,
    creation TIMESTAMP NOT NULL default now()
);

CREATE TABLE article
(
    article_id serial NOT NULL PRIMARY KEY,
    member_id int NOT NULL,
    title text NOT NULL,
    content text,
    state int NOT NULL default 1,
    creation TIMESTAMP NOT NULL default now()
);

CREATE INDEX article__member_id__idx ON article (member_id);

--
-- -- Sample Data
--

INSERT INTO member (username, state) VALUES ('user1', 1);
INSERT INTO member (username, state) VALUES ('user2', 0);
INSERT INTO member (username, state) VALUES ('user3', 1);

INSERT INTO article (member_id, title, content, state) VALUES (
    1,
    'Article one',
    'This is the first article',
    1
);

INSERT INTO article (member_id, title, content, state) VALUES (
    1,
    'Article two',
    'This is the second article',
    1
);

INSERT INTO article (member_id, title, content, state) VALUES (
    2,
    'Article three',
    'This is the third article',
    1
);

INSERT INTO article (member_id, title, content, state) VALUES (
    3,
    'Article four',
    'This is the fourth article',
    0
);

INSERT INTO article (member_id, title, content, state) VALUES (
    3,
    'Article five',
    'This is the fifth article',
    1
);

INSERT INTO article (member_id, title, content, state) VALUES (
    1,
    'Article six',
    'This is the sixth article',
    1
);

INSERT INTO article (member_id, title, content, state) VALUES (
    1,
    'Article seven',
    'This is the seventh article',
    0
);

INSERT INTO article (member_id, title, content, state) VALUES (
    1,
    'Article eight',
    'This is the eighth article',
    1
);
