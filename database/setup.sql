\c payments;
CREATE TABLE payment_card (
  id integer primary key generated always as identity,
  user_id int NOT NULL,
  name varchar(255) NOT NULL,
  number varchar(2000) NOT NULL,
  expiry varchar(5) NOT NULL,
  cv3 varchar(4) NOT NULL);

INSERT INTO payment_card (
  user_id,
  name,
  number,
  expiry,
  cv3) VALUES (
  '123',
  'Mr Nicholas Jackson',
  '12313434',
  '01/23',
  '1231');