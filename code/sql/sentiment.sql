CREATE TABLE unlabel_review(
	id	TEXT PRIMARY KEY,
	review TEXT NOT NULL
);

CREATE TABLE unlabel_review_after_splitting(
	id TEXT NOT NULL,
	word TEXT NOT NULL,
	count INTEGER NOT NULL,
	FOREIGN KEY(id) REFERENCES unlabel_review(id)
);

--foreign key will be referenced a lot
CREATE INDEX rev_id ON unlabel_review_after_splitting (id);

--sentiment will be 1 for positive word or -1 for negative word
CREATE TABLE words(
	word TEXT PRIMARY KEY,
	sentiment INTEGER NOT NULL
);

--potentially large join could be slower
SELECT r.review, r.id, CASE WHEN SUM(w.sentiment * s.`count`) >= 0 THEN 'positive' ELSE 'negative' END AS sentiment
   FROM unlabel_review r, unlabel_review_after_splitting s, words w
	WHERE w.word = s.word AND r.id = s.id;
