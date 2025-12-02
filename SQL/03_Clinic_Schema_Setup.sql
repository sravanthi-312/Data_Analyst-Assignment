-- Clinic schema (example)
CREATE TABLE clinics (
  cid VARCHAR(50) PRIMARY KEY,
  clinic_name VARCHAR(200),
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100)
);

CREATE TABLE customer (
  uid VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100),
  mobile VARCHAR(20)
);

CREATE TABLE clinic_sales (
  oid VARCHAR(50) PRIMARY KEY,
  uid VARCHAR(50),
  cid VARCHAR(50),
  amount NUMERIC(12,2),
  datetime TIMESTAMP,
  sales_channel VARCHAR(100),
  FOREIGN KEY (uid) REFERENCES customer(uid),
  FOREIGN KEY (cid) REFERENCES clinics(cid)
);

CREATE TABLE expenses (
  eid VARCHAR(50) PRIMARY KEY,
  cid VARCHAR(50),
  description TEXT,
  amount NUMERIC(12,2),
  datetime TIMESTAMP,
  FOREIGN KEY (cid) REFERENCES clinics(cid)
);

-- (Insert sample rows from PDF into these tables for testing)
