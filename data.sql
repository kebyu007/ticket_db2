CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT,
    birthdate DATE,
    phone VARCHAR(20),
    balance NUMERIC(10,2) DEFAULT 0
);

CREATE TABLE concerts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    time TIMESTAMP NOT NULL,
    size INT,
    address TEXT
);

CREATE TABLE tariffs (
    id SERIAL PRIMARY KEY,
    price NUMERIC(10,2) NOT NULL,
    position VARCHAR(50),
    date DATE,
    concert_id INT REFERENCES concerts(id)
);

CREATE TABLE tickets (
    user_id INT,
    tariff_id INT,
    amount NUMERIC(10,2),
    payment_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, tariff_id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (tariff_id) REFERENCES tariffs(id)
);

INSERT INTO users (name, age, birthdate, phone, balance) VALUES
('Ali', 22, '2003-05-12', '+998901112233', 200),
('Vali', 25, '2000-08-20', '+998901234567', 50),
('Sardor', 19, '2006-02-11', '+998909998877', 300);

INSERT INTO concerts (title, time, size, address) VALUES
('Rock Night', '2026-05-10 19:00', 5000, 'Tashkent Arena'),
('Pop Festival', '2026-06-15 20:00', 8000, 'Humo Arena');

INSERT INTO tariffs (price, position, date, concert_id) VALUES
(100, 'VIP', '2026-05-10', 1),
(60, 'Standard', '2026-05-10', 1),
(150, 'VIP', '2026-06-15', 2),
(80, 'Standard', '2026-06-15', 2);


-- SUCCESS
BEGIN;

SELECT balance
FROM users
WHERE id = 1
FOR UPDATE;

SELECT price
FROM tariffs
WHERE id = 1;

UPDATE users
SET balance = balance - (SELECT price FROM tariffs WHERE id = 1)
WHERE id = 1;

INSERT INTO tickets (user_id, tariff_id, amount)
VALUES (1, 1, (SELECT price FROM tariffs WHERE id = 1));

COMMIT;


-- FAIL
BEGIN;

SELECT balance
FROM users
WHERE id = 2
FOR UPDATE;

SELECT price
FROM tariffs
WHERE id = 1;

UPDATE users
SET balance = balance - (SELECT price FROM tariffs WHERE id = 1)
WHERE id = 2;

ROLLBACK;


-- DEADLOCK
BEGIN;

SELECT balance
FROM users
WHERE id = 1
FOR UPDATE;

SELECT price
FROM tariffs
WHERE id = 1
FOR UPDATE;

COMMIT;

BEGIN;

SELECT price
FROM tariffs
WHERE id = 1
FOR UPDATE;

SELECT balance
FROM users
WHERE id = 1
FOR UPDATE;

COMMIT;


-- SAVEPOINT
BEGIN;

SELECT balance
FROM users
WHERE id = 1
FOR UPDATE;

SELECT price
FROM tariffs
WHERE id = 1;

SAVEPOINT before_payment;

UPDATE users
SET balance = balance - (SELECT price FROM tariffs WHERE id = 1)
WHERE id = 1;

INSERT INTO tickets (user_id, tariff_id, amount)
VALUES (1, 1, (SELECT price FROM tariffs WHERE id = 1));

ROLLBACK TO SAVEPOINT before_payment;

COMMIT;