-- Hotel schema setup (example: MySQL)
CREATE TABLE users (
  user_id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100),
  phone_number VARCHAR(20),
  mail_id VARCHAR(100),
  billing_address TEXT
);

CREATE TABLE bookings (
  booking_id VARCHAR(50) PRIMARY KEY,
  booking_date TIMESTAMP,
  room_no VARCHAR(20),
  user_id VARCHAR(50),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE items (
  item_id VARCHAR(50) PRIMARY KEY,
  item_name VARCHAR(100),
  item_rate NUMERIC(10,2)
);

CREATE TABLE booking_commercials (
  id VARCHAR(50) PRIMARY KEY,
  booking_id VARCHAR(50),
  bill_id VARCHAR(50),
  bill_date TIMESTAMP,
  item_id VARCHAR(50),
  item_quantity NUMERIC(10,2),
  FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
  FOREIGN KEY (item_id) REFERENCES items(item_id)
);

-- (Sample INSERTs — add provided sample data from the PDF here)
INSERT INTO users (user_id, name, phone_number, mail_id, billing_address)
VALUES ('21wrcxuy-67erf', 'John Doe', '97XXXXXXXX', 'john.doe@example.co', 'Some Address');

INSERT INTO items (item_id, item_name, item_rate)
VALUES ('itm-a9e8-q8fu', 'Tawa Paratha', 18),
       ('itm-a07vh-aer8', 'Mix Veg', 89);
-- Add bookings and booking_commercials rows using sample data from assignment PDF for testing.

-- Add bookings and booking_commercials rows using sample data from assignment PDF for testing.
