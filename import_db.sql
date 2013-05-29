CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(4095) NOT NULL,
	author_id INTEGER NOT NULL,

	FOREIGN KEY(author_id) REFERENCES users(id)
);

CREATE TABLE question_followers (
	question_id INTEGER NOT NULL,
	follower_id INTEGER NOT NULL,

  FOREIGN KEY(question_id) REFERENCES questions(id),
	FOREIGN KEY(follower_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
	body VARCHAR(1023) NOT NULL,
	author_id INTEGER NOT NULL,
	question_id INTEGER NOT NULL,
	parent_reply_id INTEGER,

  FOREIGN KEY(question_id) REFERENCES questions(id),
	FOREIGN KEY(parent_reply_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
	question_id INTEGER NOT NULL,
	liker_id INTEGER NOT NULL,

  FOREIGN KEY(question_id) REFERENCES questions(id),
	FOREIGN KEY(liker_id) REFERENCES users(id)
);

CREATE TABLE tags (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

CREATE TABLE question_tags (
	tag_id INTEGER NOT NULL,
	question_id INTEGER NOT NULL,

	FOREIGN KEY(question_id) REFERENCES questions(id),
	FOREIGN KEY(tag_id) REFERENCES tags(id)
);


INSERT INTO questions ('title', 'body', 'author_id')
     VALUES ('N00B question:', "What's a keyboard?", 1),
		        ('Relativity', 'E=MC^2?', 3);

INSERT INTO users ('fname', 'lname')
     VALUES ('Albert', 'Einstein'), ('Kurt', 'Godel'), ('Jon', 'Wolverton'), ('Simon', 'Chaffetz');

INSERT INTO question_followers ('question_id', 'follower_id')
     VALUES (1, 3), (1, 1), (3, 2);

INSERT INTO replies ('question_id', 'body', 'author_id', 'parent_reply_id')
     VALUES (1, "You're a N00B.", 2, NULL), (1, "Dont be mean"	, 4, 1);

INSERT INTO question_likes ('question_id', 'liker_id')
     VALUES (1, 3);

INSERT INTO tags ('name')
     VALUES ('computers'), ('pysics');

INSERT INTO question_tags ('tag_id', 'question_id')
		 VALUES (1, 1), (2, 2);