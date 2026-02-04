-- Schemas
CREATE SCHEMA core;
GO
CREATE SCHEMA crew;
GO
CREATE SCHEMA customer;
GO
CREATE SCHEMA financial;
GO

-- AIRPORT table
CREATE TABLE core.AIRPORT(
    airport_id INT,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    num_of_terminals INT,
    time_zone VARCHAR(50),
	PRIMARY KEY(airport_id)
);

-- AIRCRAFT table
CREATE TABLE core.AIRCRAFT(
    aircraft_id INT,
    model VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(50) NOT NULL,
    year_of_manufacture INT,
    last_maintenance_date DATE,
    status VARCHAR(20),
    total_seats INT,
	PRIMARY KEY(aircraft_id)
);

-- ROUTE table
CREATE TABLE core.ROUTE(
   	--FKs
    origin_airport_id INT NOT NULL,
    destination_airport_id INT NOT NULL,

	--entity attributes
	route_id INT,
	distance DECIMAL(10,2),
	avg_duration TIME,

	PRIMARY KEY(route_id),
    FOREIGN KEY(origin_airport_id) REFERENCES core.AIRPORT(airport_id),
    FOREIGN KEY(destination_airport_id) REFERENCES core.AIRPORT(airport_id)
);

-- SCHEDULE table
CREATE TABLE core.SCHEDULE(
    schedule_id INT,
    effective_from DATE NOT NULL,
    effective_to DATE,
    flight_duration TIME,
	recurrence_pattern VARCHAR(50) NOT NULL,
	PRIMARY KEY(schedule_id)
);

-- FLIGHT table
CREATE TABLE core.FLIGHT(
    --FKs
    route_id INT NOT NULL,
    schedule_id INT NOT NULL,
    aircraft_id INT NOT NULL,

	--entity attributes
	flight_id INT,
	flight_num VARCHAR(10) NOT NULL UNIQUE,
    status VARCHAR(20),
    gate VARCHAR(10),

	--relationship attributes (departs_from, arrives_at)
	scheduled_departure_time DATETIME NOT NULL,
    scheduled_arrival_time DATETIME,
    actual_departure_time DATETIME,
    actual_arrival_time DATETIME,

	PRIMARY KEY(flight_id),
    FOREIGN KEY(route_id) REFERENCES core.ROUTE(route_id),
    FOREIGN KEY(schedule_id) REFERENCES core.SCHEDULE(schedule_id),
    FOREIGN KEY(aircraft_id) REFERENCES core.AIRCRAFT(aircraft_id)
);

-- EMPLOYEE table (superclass)
CREATE TABLE crew.EMPLOYEE(
    employee_id INT PRIMARY KEY,
    f_name VARCHAR(50) NOT NULL,
    L_name VARCHAR(50) NOT NULL,
    m_name VARCHAR(50),
    date_of_birth DATE NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(20),
);

-- FLIGHT CREW table (subclass of EMPLOYEE)
CREATE TABLE crew.FLIGHT_CREW(
    employee_id INT,
    yrs_of_experience INT,
	PRIMARY KEY(employee_id),
    FOREIGN KEY(employee_id) REFERENCES crew.EMPLOYEE(employee_id)
);

-- GROUND STAFF table (subclass of EMPLOYEE)
CREATE TABLE crew.GROUND_STAFF(
    employee_id INT,
    department VARCHAR(50),
    position VARCHAR(50),
	shift_pattern VARCHAR(50),
	PRIMARY KEY(employee_id),
    FOREIGN KEY(employee_id) REFERENCES crew.EMPLOYEE(employee_id)
);

-- PILOT table (subclass of FLIGHT_CREW)
CREATE TABLE crew.PILOT(
    employee_id INT,
    aircraft_type_rating VARCHAR(50),
    pilot_license_type VARCHAR(50),
    flight_hours INT,
	PRIMARY KEY(employee_id),
    FOREIGN KEY(employee_id) REFERENCES crew.FLIGHT_CREW(employee_id)
);

-- FLIGHT_ATTENDANT table (subclass of FLIGHT_CREW)
CREATE TABLE crew.FLIGHT_ATTENDANT(
    employee_id INT,
    language_spoken VARCHAR(100),
    safety_training_level VARCHAR(50),
	PRIMARY KEY(employee_id),
    FOREIGN KEY(employee_id) REFERENCES crew.FLIGHT_CREW(employee_id)
);

-- CREW_ASSIGNMENT table
CREATE TABLE crew.CREW_ASSIGNMENT(
	--entity attributes
    assignment_id INT,
	role VARCHAR(50) NOT NULL,

	--FKs
    employee_id INT NOT NULL,
    flight_id INT NOT NULL,
    
	--relationship attributes
    assignment_status VARCHAR(20) NOT NULL,
    date DATE NOT NULL,

	PRIMARY KEY(assignment_id),
    FOREIGN KEY(employee_id) REFERENCES crew.EMPLOYEE(employee_id),
    FOREIGN KEY(flight_id) REFERENCES core.FLIGHT(flight_id)
);

-- PASSENGER table (superclass)
CREATE TABLE customer.PASSENGER(
    passenger_id INT PRIMARY KEY,
    f_name VARCHAR(50) NOT NULL,
    L_name VARCHAR(50) NOT NULL,
    m_name VARCHAR(50),
    date_of_birth DATE,
    gender CHAR(1) CHECK (gender IN ('F', 'M', 'O')),
    email VARCHAR(100),
    phone_number VARCHAR(20),
    has_booking BIT
);

-- OCCASIONAL table (subclass of PASSENGER)
CREATE TABLE customer.OCCASIONAL(
    passenger_id INT,
    last_flight_date DATE,
	total_flights_taken INT,
	PRIMARY KEY(passenger_id),
    FOREIGN KEY(passenger_id) REFERENCES customer.PASSENGER(passenger_id)
);

-- FREQUENT_FLYER table (subclass of PASSENGER)
CREATE TABLE customer.FREQUENT_FLYER(
    passenger_id INT,
    join_date DATE,
	membership_num VARCHAR(10),
	membership_level VARCHAR(50),
	PRIMARY KEY(passenger_id),
    FOREIGN KEY(passenger_id) REFERENCES customer.PASSENGER(passenger_id)
);

-- SEAT table
CREATE TABLE core.SEAT(
    seat_id INT,
    aircraft_id INT NOT NULL,
	seat_num VARCHAR(10) NOT NULL UNIQUE,
    row_num INT NOT NULL,
    column_letter CHAR(1) NOT NULL,
    class VARCHAR(20) NOT NULL,
    is_reserved BIT DEFAULT 0,
	reservation_date DATE,
	PRIMARY KEY(seat_id),
    FOREIGN KEY(aircraft_id) REFERENCES core.AIRCRAFT(aircraft_id)
);

-- BOOKING table
CREATE TABLE customer.BOOKING(
	--entity attributes
    booking_id INT,
	date DATETIME NOT NULL,
    status VARCHAR(20),
	type VARCHAR(50) CHECK (type IN ('online', 'counter')) NOT NULL,

	--specific type attributes
	device_type VARCHAR(50),
	agent_id INT,
	location VARCHAR(50),

	--FKs
    passenger_id INT NOT NULL,
    flight_id INT NOT NULL,
	seat_id INT NOT NULL,
    PRIMARY KEY(booking_id),
    FOREIGN KEY(passenger_id) REFERENCES customer.PASSENGER(passenger_id),
    FOREIGN KEY(flight_id) REFERENCES core.FLIGHT(flight_id),
	FOREIGN KEY(seat_id) REFERENCES core.SEAT(seat_id)
);

-- Create PAYMENT table
CREATE TABLE financial.PAYMENT (
	--entity attributes
    payment_id INT,
	method VARCHAR(50) CHECK (method IN ('credit card', 'bank transfer', 'loyality points')) NOT NULL,
    transaction_status VARCHAR(20),

	--FKs
    booking_id INT NOT NULL,

	--relationship attributes
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_date DATETIME NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
	
	PRIMARY KEY(payment_id),
    FOREIGN KEY(booking_id) REFERENCES customer.BOOKING(booking_id)
);

-- CREDIT_CARD table (subclass of PAYMENT)
CREATE TABLE financial.CREDIT_CARD(
    payment_id INT,
    card_last_four_digits VARCHAR(4) NOT NULL,
    type VARCHAR(20),
	authorization_code VARCHAR(6) NOT NULL,
	PRIMARY KEY(payment_id),
    FOREIGN KEY(payment_id) REFERENCES financial.PAYMENT(payment_id)
);

-- BANK_TRANSFER table (subclass of PAYMENT)
CREATE TABLE financial.BANK_TRANSFER(
    payment_id INT,
    bank_name VARCHAR(50) NOT NULL,
    reference_number VARCHAR(50) NOT NULL,
    acc_last_four_digits VARCHAR(4),
	PRIMARY KEY(payment_id),
    FOREIGN KEY(payment_id) REFERENCES financial.PAYMENT(payment_id)
);

-- LOYALTY_POINTS table (subclass of PAYMENT)
CREATE TABLE financial.LOYALTY_POINTS(
    payment_id INT,
	points_redeemed INT DEFAULT 0,
	points_after_balance INT DEFAULT 0,
	PRIMARY KEY(payment_id),
    FOREIGN KEY(payment_id) REFERENCES financial.PAYMENT(payment_id)
);

-- BAGGAGE table (superclass)
CREATE TABLE customer.BAGGAGE (
	--entity attributes
    baggage_id INT,
    weight DECIMAL(5,2) NOT NULL,
    status VARCHAR(20),
	type VARCHAR(50) CHECK (type IN ('checked', 'carry on', 'special')) NOT NULL,

	--specific type attributes
	security_scan_status VARCHAR(50),
    cabin_storage_location VARCHAR(50),
	fee DECIMAL(10,2),

	--FKs
	passenger_id INT NOT NULL,
    booking_id INT NOT NULL,
	PRIMARY KEY(baggage_id),
    FOREIGN KEY(booking_id) REFERENCES customer.BOOKING(booking_id)
);

/*INSERT COMMANDS*/
-- AIRPORT table records
INSERT INTO core.AIRPORT (airport_id, code, name, city, country, num_of_terminals, time_zone) VALUES 
(1, 'JFK', 'John F. Kennedy International Airport', 'New York', 'USA', 6, 'EST'),
(2, 'LAX', 'Los Angeles International Airport', 'Los Angeles', 'USA', 9, 'PST'),
(3, 'LHR', 'Heathrow Airport', 'London', 'UK', 5, 'GMT'),
(4, 'CDG', 'Charles de Gaulle Airport', 'Paris', 'France', 3, 'CET'),
(5, 'DXB', 'Dubai International Airport', 'Dubai', 'UAE', 3, 'GST'),
(6, 'HND', 'Haneda Airport', 'Tokyo', 'Japan', 3, 'JST'),
(7, 'SYD', 'Sydney Airport', 'Sydney', 'Australia', 3, 'AEST'),
(8, 'SFO', 'San Francisco International Airport', 'San Francisco', 'USA', 4, 'PST'),
(9, 'ORD', 'O Hare International Airport', 'Chicago', 'USA', 4, 'CST'),
(10, 'PEK', 'Beijing Capital International Airport', 'Beijing', 'China', 3, 'CST'),
(11, 'FRA', 'Frankfurt Airport', 'Frankfurt', 'Germany', 2, 'CET'),
(12, 'AMS', 'Amsterdam Airport Schiphol', 'Amsterdam', 'Netherlands', 1, 'CET'),
(13, 'ICN', 'Incheon International Airport', 'Seoul', 'South Korea', 2, 'KST'),
(14, 'SIN', 'Singapore Changi Airport', 'Singapore', 'Singapore', 4, 'SGT'),
(15, 'DEN', 'Denver International Airport', 'Denver', 'USA', 3, 'MST'),
(16, 'BKK', 'Suvarnabhumi Airport', 'Bangkok', 'Thailand', 1, 'ICT'),
(17, 'MAD', 'Adolfo Suárez Madrid–Barajas Airport', 'Madrid', 'Spain', 4, 'CET'),
(18, 'YYZ', 'Toronto Pearson International Airport', 'Toronto', 'Canada', 2, 'EST'),
(19, 'MIA', 'Miami International Airport', 'Miami', 'USA', 3, 'EST'),
(20, 'IST', 'Istanbul Airport', 'Istanbul', 'Turkey', 2, 'TRT'),
(21, 'MUC', 'Munich Airport', 'Munich', 'Germany', 2, 'CET'),
(22, 'HKG', 'Hong Kong International Airport', 'Hong Kong', 'China', 2, 'HKT'),
(23, 'KUL', 'Kuala Lumpur International Airport', 'Kuala Lumpur', 'Malaysia', 2, 'MYT'),
(24, 'GRU', 'São Paulo/Guarulhos International Airport', 'São Paulo', 'Brazil', 2, 'BRT'),
(25, 'DEL', 'Indira Gandhi International Airport', 'Delhi', 'India', 3, 'IST'),
(26, 'CPH', 'Copenhagen Airport', 'Copenhagen', 'Denmark', 3, 'CET'),
(27, 'ATL', 'Hartsfield-Jackson Atlanta International Airport', 'Atlanta', 'USA', 2, 'EST'),
(28, 'DOH', 'Hamad International Airport', 'Doha', 'Qatar', 1, 'AST'),
(29, 'MEX', 'Mexico City International Airport', 'Mexico City', 'Mexico', 2, 'CST'),
(30, 'AKL', 'Auckland Airport', 'Auckland', 'New Zealand', 1, 'NZST');

-- AIRCRAFT table records
INSERT INTO core.AIRCRAFT (aircraft_id, model, manufacturer, year_of_manufacture, last_maintenance_date, status, total_seats) VALUES 
(1, 'Boeing 737-800', 'Boeing', 2018, '2023-01-15', 'Active', 162),
(2, 'Airbus A320', 'Airbus', 2019, '2023-02-20', 'Active', 150),
(3, 'Boeing 787-9', 'Boeing', 2020, '2023-03-10', 'Active', 290),
(4, 'Airbus A350', 'Airbus', 2021, '2023-01-30', 'Active', 325),
(5, 'Boeing 777-300ER', 'Boeing', 2017, '2023-04-05', 'Active', 396),
(6, 'Airbus A380', 'Airbus', 2016, '2023-02-15', 'Maintenance', 517),
(7, 'Boeing 747-8', 'Boeing', 2015, '2023-03-25', 'Active', 410),
(8, 'Embraer E190', 'Embraer', 2020, '2023-01-10', 'Active', 100),
(9, 'Bombardier CRJ900', 'Bombardier', 2019, '2023-04-01', 'Active', 90),
(10, 'Airbus A321neo', 'Airbus', 2022, '2023-03-15', 'Active', 240),
(11, 'Boeing 737 MAX 8', 'Boeing', 2021, '2023-02-28', 'Active', 178),
(12, 'Airbus A330-300', 'Airbus', 2018, '2023-01-20', 'Active', 277),
(13, 'Boeing 767-300', 'Boeing', 2017, '2023-03-05', 'Active', 218),
(14, 'Airbus A319', 'Airbus', 2016, '2023-04-10', 'Active', 124),
(15, 'Boeing 757-200', 'Boeing', 2015, '2023-02-15', 'Maintenance', 200),
(16, 'Embraer E175', 'Embraer', 2021, '2023-01-25', 'Active', 76),
(17, 'Bombardier Q400', 'Bombardier', 2020, '2023-03-20', 'Active', 78),
(18, 'Airbus A220-300', 'Airbus', 2022, '2023-04-05', 'Active', 130),
(19, 'Boeing 737-900ER', 'Boeing', 2019, '2023-02-10', 'Active', 180),
(20, 'Airbus A321', 'Airbus', 2018, '2023-01-30', 'Active', 220),
(21, 'Boeing 777-200', 'Boeing', 2017, '2023-03-15', 'Active', 305),
(22, 'Airbus A340-600', 'Airbus', 2016, '2023-04-01', 'Active', 380),
(23, 'Boeing 787-8', 'Boeing', 2021, '2023-02-20', 'Active', 242),
(24, 'Airbus A330-200', 'Airbus', 2020, '2023-01-15', 'Active', 246),
(25, 'Boeing 737-700', 'Boeing', 2019, '2023-03-10', 'Active', 126),
(26, 'Airbus A318', 'Airbus', 2018, '2023-04-15', 'Active', 107),
(27, 'Boeing 767-400ER', 'Boeing', 2017, '2023-02-25', 'Active', 245),
(28, 'Airbus A350-1000', 'Airbus', 2022, '2023-01-20', 'Active', 366),
(29, 'Boeing 777-200LR', 'Boeing', 2021, '2023-03-05', 'Active', 301),
(30, 'Airbus A380-800', 'Airbus', 2020, '2023-04-10', 'Maintenance', 525);

-- ROUTE table records
INSERT INTO core.ROUTE (route_id, origin_airport_id, destination_airport_id, distance, avg_duration) VALUES 
(1, 1, 2, 2475, '05:30:00'),
(2, 2, 3, 5456, '11:15:00'),
(3, 3, 4, 214, '01:10:00'),
(4, 4, 5, 3278, '06:45:00'),
(5, 5, 6, 5853, '08:30:00'),
(6, 6, 7, 4872, '09:20:00'),
(7, 7, 8, 7423, '13:45:00'),
(8, 8, 9, 1854, '04:10:00'),
(9, 9, 10, 10650, '14:30:00'),
(10, 10, 11, 4578, '09:15:00'),
(11, 11, 12, 223, '01:05:00'),
(12, 12, 13, 5256, '10:40:00'),
(13, 13, 14, 3298, '06:30:00'),
(14, 14, 15, 9876, '18:20:00'),
(15, 15, 16, 8567, '16:45:00'),
(16, 16, 17, 5876, '12:30:00'),
(17, 17, 18, 4231, '08:15:00'),
(18, 18, 19, 1254, '02:45:00'),
(19, 19, 20, 6543, '12:10:00'),
(20, 20, 21, 876, '02:15:00'),
(21, 21, 22, 5432, '10:50:00'),
(22, 22, 23, 1567, '03:40:00'),
(23, 23, 24, 9876, '19:15:00'),
(24, 24, 25, 8765, '17:30:00'),
(25, 25, 26, 5432, '10:45:00'),
(26, 26, 27, 4321, '08:20:00'),
(27, 27, 28, 7654, '14:10:00'),
(28, 28, 29, 8765, '16:30:00'),
(29, 29, 30, 7654, '14:50:00'),
(30, 30, 1, 8765, '16:15:00');

-- SCHEDULE table records
INSERT INTO core.SCHEDULE (schedule_id, effective_from, effective_to, flight_duration, recurrence_pattern) VALUES 
(1, '2023-01-01', '2023-12-31', '05:30:00', 'Daily'),
(2, '2023-01-01', '2023-12-31', '11:15:00', 'Daily'),
(3, '2023-01-01', '2023-12-31', '01:10:00', 'Weekdays'),
(4, '2023-01-01', '2023-12-31', '06:45:00', 'Daily'),
(5, '2023-01-01', '2023-12-31', '08:30:00', 'Daily'),
(6, '2023-01-01', '2023-12-31', '09:20:00', 'Weekends'),
(7, '2023-01-01', '2023-12-31', '13:45:00', 'Daily'),
(8, '2023-01-01', '2023-12-31', '04:10:00', 'Weekdays'),
(9, '2023-01-01', '2023-12-31', '14:30:00', 'Daily'),
(10, '2023-01-01', '2023-12-31', '09:15:00', 'Daily'),
(11, '2023-01-01', '2023-12-31', '01:05:00', 'Weekdays'),
(12, '2023-01-01', '2023-12-31', '10:40:00', 'Daily'),
(13, '2023-01-01', '2023-12-31', '06:30:00', 'Daily'),
(14, '2023-01-01', '2023-12-31', '18:20:00', 'Weekends'),
(15, '2023-01-01', '2023-12-31', '16:45:00', 'Daily'),
(16, '2023-01-01', '2023-12-31', '12:30:00', 'Daily'),
(17, '2023-01-01', '2023-12-31', '08:15:00', 'Weekdays'),
(18, '2023-01-01', '2023-12-31', '02:45:00', 'Daily'),
(19, '2023-01-01', '2023-12-31', '12:10:00', 'Daily'),
(20, '2023-01-01', '2023-12-31', '02:15:00', 'Weekends'),
(21, '2023-01-01', '2023-12-31', '10:50:00', 'Daily'),
(22, '2023-01-01', '2023-12-31', '03:40:00', 'Daily'),
(23, '2023-01-01', '2023-12-31', '19:15:00', 'Weekdays'),
(24, '2023-01-01', '2023-12-31', '17:30:00', 'Daily'),
(25, '2023-01-01', '2023-12-31', '10:45:00', 'Daily'),
(26, '2023-01-01', '2023-12-31', '08:20:00', 'Weekends'),
(27, '2023-01-01', '2023-12-31', '14:10:00', 'Daily'),
(28, '2023-01-01', '2023-12-31', '16:30:00', 'Daily'),
(29, '2023-01-01', '2023-12-31', '14:50:00', 'Weekdays'),
(30, '2023-01-01', '2023-12-31', '16:15:00', 'Daily');

-- FLIGHT table records
INSERT INTO core.FLIGHT (flight_id, route_id, schedule_id, aircraft_id, flight_num, status, gate, scheduled_departure_time, scheduled_arrival_time, actual_departure_time, actual_arrival_time) VALUES 
(1, 1, 1, 1, 'AA100', 'On Time', 'A12', '2023-05-01 08:00:00', '2023-05-01 13:30:00', '2023-05-01 08:05:00', '2023-05-01 13:25:00'),
(2, 2, 2, 2, 'AA101', 'Delayed', 'B34', '2023-05-01 10:00:00', '2023-05-01 21:15:00', '2023-05-01 10:30:00', '2023-05-01 21:45:00'),
(3, 3, 3, 3, 'AA102', 'On Time', 'C45', '2023-05-01 12:00:00', '2023-05-01 13:10:00', '2023-05-01 12:00:00', '2023-05-01 13:05:00'),
(4, 4, 4, 4, 'AA103', 'Cancelled', 'D23', '2023-05-01 14:00:00', '2023-05-01 20:45:00', NULL, NULL),
(5, 5, 5, 5, 'AA104', 'On Time', 'E56', '2023-05-01 16:00:00', '2023-05-02 00:30:00', '2023-05-01 16:00:00', '2023-05-02 00:25:00'),
(6, 6, 6, 6, 'AA105', 'Delayed', 'F78', '2023-05-01 18:00:00', '2023-05-02 03:20:00', '2023-05-01 18:30:00', '2023-05-02 03:50:00'),
(7, 7, 7, 7, 'AA106', 'On Time', 'G89', '2023-05-01 20:00:00', '2023-05-02 09:45:00', '2023-05-01 20:05:00', '2023-05-02 09:40:00'),
(8, 8, 8, 8, 'AA107', 'On Time', 'H12', '2023-05-02 08:00:00', '2023-05-02 12:10:00', '2023-05-02 08:00:00', '2023-05-02 12:05:00'),
(9, 9, 9, 9, 'AA108', 'Delayed', 'I34', '2023-05-02 10:00:00', '2023-05-02 00:30:00', '2023-05-02 10:45:00', '2023-05-03 01:15:00'),
(10, 10, 10, 10, 'AA109', 'On Time', 'J45', '2023-05-02 12:00:00', '2023-05-02 21:15:00', '2023-05-02 12:00:00', '2023-05-02 21:10:00'),
(11, 11, 11, 11, 'AA110', 'On Time', 'K23', '2023-05-02 14:00:00', '2023-05-02 15:05:00', '2023-05-02 14:00:00', '2023-05-02 15:00:00'),
(12, 12, 12, 12, 'AA111', 'Cancelled', 'L56', '2023-05-02 16:00:00', '2023-05-03 02:40:00', NULL, NULL),
(13, 13, 13, 13, 'AA112', 'On Time', 'M78', '2023-05-02 18:00:00', '2023-05-03 00:30:00', '2023-05-02 18:00:00', '2023-05-03 00:25:00'),
(14, 14, 14, 14, 'AA113', 'Delayed', 'N89', '2023-05-02 20:00:00', '2023-05-03 14:20:00', '2023-05-02 20:30:00', '2023-05-03 14:50:00'),
(15, 15, 15, 15, 'AA114', 'On Time', 'O12', '2023-05-03 08:00:00', '2023-05-04 00:45:00', '2023-05-03 08:00:00', '2023-05-04 00:40:00'),
(16, 16, 16, 16, 'AA115', 'On Time', 'P34', '2023-05-03 10:00:00', '2023-05-03 22:30:00', '2023-05-03 10:00:00', '2023-05-03 22:25:00'),
(17, 17, 17, 17, 'AA116', 'Delayed', 'Q45', '2023-05-03 12:00:00', '2023-05-03 20:15:00', '2023-05-03 12:30:00', '2023-05-03 20:45:00'),
(18, 18, 18, 18, 'AA117', 'On Time', 'R23', '2023-05-03 14:00:00', '2023-05-03 16:45:00', '2023-05-03 14:00:00', '2023-05-03 16:40:00'),
(19, 19, 19, 19, 'AA118', 'On Time', 'S56', '2023-05-03 16:00:00', '2023-05-04 04:10:00', '2023-05-03 16:00:00', '2023-05-04 04:05:00'),
(20, 20, 20, 20, 'AA119', 'Cancelled', 'T78', '2023-05-03 18:00:00', '2023-05-03 20:15:00', NULL, NULL),
(21, 21, 21, 21, 'AA120', 'On Time', 'U89', '2023-05-03 20:00:00', '2023-05-04 06:50:00', '2023-05-03 20:00:00', '2023-05-04 06:45:00'),
(22, 22, 22, 22, 'AA121', 'Delayed', 'V12', '2023-05-04 08:00:00', '2023-05-04 11:40:00', '2023-05-04 08:30:00', '2023-05-04 12:10:00'),
(23, 23, 23, 23, 'AA122', 'On Time', 'W34', '2023-05-04 10:00:00', '2023-05-05 05:15:00', '2023-05-04 10:00:00', '2023-05-05 05:10:00'),
(24, 24, 24, 24, 'AA123', 'On Time', 'X45', '2023-05-04 12:00:00', '2023-05-05 05:30:00', '2023-05-04 12:00:00', '2023-05-05 05:25:00'),
(25, 25, 25, 25, 'AA124', 'Delayed', 'Y23', '2023-05-04 14:00:00', '2023-05-05 00:45:00', '2023-05-04 14:30:00', '2023-05-05 01:15:00'),
(26, 26, 26, 26, 'AA125', 'On Time', 'Z56', '2023-05-04 16:00:00', '2023-05-05 00:20:00', '2023-05-04 16:00:00', '2023-05-05 00:15:00'),
(27, 27, 27, 27, 'AA126', 'On Time', 'A78', '2023-05-04 18:00:00', '2023-05-05 08:10:00', '2023-05-04 18:00:00', '2023-05-05 08:05:00'),
(28, 28, 28, 28, 'AA127', 'Cancelled', 'B89', '2023-05-04 20:00:00', '2023-05-05 12:30:00', NULL, NULL),
(29, 29, 29, 29, 'AA128', 'On Time', 'C12', '2023-05-05 08:00:00', '2023-05-05 22:50:00', '2023-05-05 08:00:00', '2023-05-05 22:45:00'),
(30, 30, 30, 30, 'AA129', 'Delayed', 'D34', '2023-05-05 10:00:00', '2023-05-06 02:15:00', '2023-05-05 10:30:00', '2023-05-06 02:45:00');

-- EMPLOYEE table records
INSERT INTO crew.EMPLOYEE (employee_id, f_name, L_name, m_name, date_of_birth, hire_date, salary, email, phone_number) VALUES 
(1, 'John', 'Smith', 'A', '1980-05-15', '2010-06-20', 85000, 'john.smith@airline.com', '555-0101'),
(2, 'Sarah', 'Johnson', 'B', '1985-08-22', '2012-03-15', 78000, 'sarah.johnson@airline.com', '555-0102'),
(3, 'Michael', 'Williams', 'C', '1978-11-30', '2008-09-10', 92000, 'michael.williams@airline.com', '555-0103'),
(4, 'Emily', 'Brown', 'D', '1990-02-14', '2015-07-22', 68000, 'emily.brown@airline.com', '555-0104'),
(5, 'David', 'Jones', 'E', '1982-07-19', '2011-04-05', 88000, 'david.jones@airline.com', '555-0105'),
(6, 'Jessica', 'Garcia', 'F', '1987-04-25', '2013-08-18', 75000, 'jessica.garcia@airline.com', '555-0106'),
(7, 'Daniel', 'Miller', 'G', '1975-09-12', '2005-11-30', 95000, 'daniel.miller@airline.com', '555-0107'),
(8, 'Olivia', 'Davis', 'H', '1992-01-08', '2016-05-14', 65000, 'olivia.davis@airline.com', '555-0108'),
(9, 'Robert', 'Rodriguez', 'I', '1983-06-17', '2010-10-25', 87000, 'robert.rodriguez@airline.com', '555-0109'),
(10, 'Sophia', 'Martinez', 'J', '1988-03-21', '2014-02-11', 72000, 'sophia.martinez@airline.com', '555-0110'),
(11, 'James', 'Hernandez', 'K', '1979-12-05', '2007-07-08', 93000, 'james.hernandez@airline.com', '555-0111'),
(12, 'Isabella', 'Lopez', 'L', '1991-08-30', '2015-09-19', 67000, 'isabella.lopez@airline.com', '555-0112'),
(13, 'William', 'Gonzalez', 'M', '1981-05-24', '2009-12-01', 89000, 'william.gonzalez@airline.com', '555-0113'),
(14, 'Mia', 'Wilson', 'N', '1986-10-11', '2012-11-22', 77000, 'mia.wilson@airline.com', '555-0114'),
(15, 'Benjamin', 'Anderson', 'O', '1977-07-07', '2004-08-15', 98000, 'benjamin.anderson@airline.com', '555-0115'),
(16, 'Charlotte', 'Thomas', 'P', '1993-02-28', '2017-04-03', 63000, 'charlotte.thomas@airline.com', '555-0116'),
(17, 'Jacob', 'Taylor', 'Q', '1984-09-16', '2011-01-27', 86000, 'jacob.taylor@airline.com', '555-0117'),
(18, 'Amelia', 'Moore', 'R', '1989-04-09', '2013-06-12', 74000, 'amelia.moore@airline.com', '555-0118'),
(19, 'Ethan', 'Jackson', 'S', '1980-11-23', '2006-10-05', 91000, 'ethan.jackson@airline.com', '555-0119'),
(20, 'Abigail', 'Martin', 'T', '1994-01-17', '2018-03-28', 62000, 'abigail.martin@airline.com', '555-0120'),
(21, 'Alexander', 'Lee', 'U', '1983-08-14', '2010-07-09', 85000, 'alexander.lee@airline.com', '555-0121'),
(22, 'Elizabeth', 'Perez', 'V', '1987-05-19', '2012-12-24', 76000, 'elizabeth.perez@airline.com', '555-0122'),
(23, 'Matthew', 'Thompson', 'W', '1976-12-31', '2003-05-18', 99000, 'matthew.thompson@airline.com', '555-0123'),
(24, 'Avery', 'White', 'X', '1995-03-26', '2019-08-07', 61000, 'avery.white@airline.com', '555-0124'),
(25, 'Andrew', 'Harris', 'Y', '1982-10-08', '2009-02-14', 88000, 'andrew.harris@airline.com', '555-0125'),
(26, 'Ella', 'Sanchez', 'Z', '1988-07-03', '2014-01-29', 73000, 'ella.sanchez@airline.com', '555-0126'),
(27, 'Joshua', 'Clark', 'AA', '1978-04-12', '2005-09-20', 94000, 'joshua.clark@airline.com', '555-0127'),
(28, 'Scarlett', 'Ramirez', 'AB', '1990-09-05', '2016-11-11', 66000, 'scarlett.ramirez@airline.com', '555-0128'),
(29, 'Christopher', 'Lewis', 'AC', '1981-02-18', '2008-04-02', 90000, 'christopher.lewis@airline.com', '555-0129'),
(30, 'Madison', 'Robinson', 'AD', '1986-11-27', '2011-10-16', 79000, 'madison.robinson@airline.com', '555-0130');

-- FLIGHT_CREW table records
INSERT INTO crew.FLIGHT_CREW (employee_id, yrs_of_experience) VALUES 
(1, 12),
(2, 10),
(3, 15),
(4, 7),
(5, 11),
(6, 9),
(7, 18),
(8, 6),
(9, 12),
(10, 8),
(11, 16),
(12, 7),
(13, 13),
(14, 10),
(15, 19),
(16, 5),
(17, 11),
(18, 9),
(19, 17),
(20, 4),
(21, 12),
(22, 10),
(23, 20),
(24, 3),
(25, 14),
(26, 9),
(27, 18),
(28, 7),
(29, 15),
(30, 11);

-- GROUND_STAFF table records
INSERT INTO crew.GROUND_STAFF (employee_id, department, position, shift_pattern) VALUES 
(1, 'Operations', 'Manager', 'Day'),
(2, 'Customer Service', 'Supervisor', 'Evening'),
(3, 'Maintenance', 'Technician', 'Night'),
(4, 'Baggage', 'Handler', 'Rotating'),
(5, 'Security', 'Officer', 'Day'),
(6, 'Administration', 'Coordinator', 'Evening'),
(7, 'Operations', 'Director', 'Day'),
(8, 'Customer Service', 'Agent', 'Rotating'),
(9, 'Maintenance', 'Engineer', 'Night'),
(10, 'Baggage', 'Supervisor', 'Day'),
(11, 'Security', 'Manager', 'Evening'),
(12, 'Administration', 'Assistant', 'Day'),
(13, 'Operations', 'Supervisor', 'Rotating'),
(14, 'Customer Service', 'Manager', 'Day'),
(15, 'Maintenance', 'Director', 'Night'),
(16, 'Baggage', 'Handler', 'Evening'),
(17, 'Security', 'Officer', 'Rotating'),
(18, 'Administration', 'Coordinator', 'Day'),
(19, 'Operations', 'Agent', 'Evening'),
(20, 'Customer Service', 'Representative', 'Day'),
(21, 'Maintenance', 'Technician', 'Night'),
(22, 'Baggage', 'Supervisor', 'Rotating'),
(23, 'Security', 'Manager', 'Day'),
(24, 'Administration', 'Assistant', 'Evening'),
(25, 'Operations', 'Coordinator', 'Day'),
(26, 'Customer Service', 'Agent', 'Rotating'),
(27, 'Maintenance', 'Engineer', 'Night'),
(28, 'Baggage', 'Handler', 'Day'),
(29, 'Security', 'Officer', 'Evening'),
(30, 'Administration', 'Director', 'Day');

-- PILOT table records
INSERT INTO crew.PILOT (employee_id, aircraft_type_rating, pilot_license_type, flight_hours) VALUES 
(1, 'Boeing 737', 'ATP', 8500),
(2, 'Airbus A320', 'ATP', 7200),
(3, 'Boeing 787', 'ATP', 9800),
(4, 'Airbus A350', 'ATP', 6500),
(5, 'Boeing 777', 'ATP', 8900),
(6, 'Airbus A380', 'ATP', 7500),
(7, 'Boeing 747', 'ATP', 10200),
(8, 'Embraer E190', 'ATP', 6000),
(9, 'Bombardier CRJ900', 'ATP', 8700),
(10, 'Airbus A321', 'ATP', 7300),
(11, 'Boeing 737 MAX', 'ATP', 9500),
(12, 'Airbus A330', 'ATP', 6800),
(13, 'Boeing 767', 'ATP', 9100),
(14, 'Airbus A319', 'ATP', 7700),
(15, 'Boeing 757', 'ATP', 10500),
(16, 'Embraer E175', 'ATP', 5800),
(17, 'Bombardier Q400', 'ATP', 8600),
(18, 'Airbus A220', 'ATP', 7400),
(19, 'Boeing 737-900', 'ATP', 9900),
(20, 'Airbus A321neo', 'ATP', 6200),
(21, 'Boeing 777-200', 'ATP', 8800),
(22, 'Airbus A340', 'ATP', 7600),
(23, 'Boeing 787-8', 'ATP', 10700),
(24, 'Airbus A330-200', 'ATP', 5500),
(25, 'Boeing 737-700', 'ATP', 9000),
(26, 'Airbus A318', 'ATP', 7800),
(27, 'Boeing 767-400', 'ATP', 10400),
(28, 'Airbus A350-1000', 'ATP', 6700),
(29, 'Boeing 777-200LR', 'ATP', 9300),
(30, 'Airbus A380-800', 'ATP', 8100);

-- FLIGHT_ATTENDANT table records
INSERT INTO crew.FLIGHT_ATTENDANT (employee_id, language_spoken, safety_training_level) VALUES 
(1, 'English, Spanish', 'Advanced'),
(2, 'English, French', 'Intermediate'),
(3, 'English, German', 'Advanced'),
(4, 'English, Mandarin', 'Basic'),
(5, 'English, Arabic', 'Advanced'),
(6, 'English, Japanese', 'Intermediate'),
(7, 'English, Russian', 'Advanced'),
(8, 'English, Portuguese', 'Basic'),
(9, 'English, Italian', 'Advanced'),
(10, 'English, Korean', 'Intermediate'),
(11, 'English, Hindi', 'Advanced'),
(12, 'English, Cantonese', 'Basic'),
(13, 'English, Dutch', 'Advanced'),
(14, 'English, Swedish', 'Intermediate'),
(15, 'English, Finnish', 'Advanced'),
(16, 'English, Turkish', 'Basic'),
(17, 'English, Greek', 'Advanced'),
(18, 'English, Hebrew', 'Intermediate'),
(19, 'English, Polish', 'Advanced'),
(20, 'English, Thai', 'Basic'),
(21, 'English, Vietnamese', 'Advanced'),
(22, 'English, Malay', 'Intermediate'),
(23, 'English, Norwegian', 'Advanced'),
(24, 'English, Danish', 'Basic'),
(25, 'English, Czech', 'Advanced'),
(26, 'English, Hungarian', 'Intermediate'),
(27, 'English, Romanian', 'Advanced'),
(28, 'English, Filipino', 'Basic'),
(29, 'English, Indonesian', 'Advanced'),
(30, 'English, Bengali', 'Intermediate');

-- CREW_ASSIGNMENT table records
INSERT INTO crew.CREW_ASSIGNMENT (assignment_id, employee_id, flight_id, role, assignment_status, date) VALUES 
(1, 1, 1, 'Captain', 'Completed', '2023-05-01'),
(2, 2, 1, 'First Officer', 'Completed', '2023-05-01'),
(3, 3, 2, 'Captain', 'Completed', '2023-05-01'),
(4, 4, 2, 'First Officer', 'Completed', '2023-05-01'),
(5, 5, 3, 'Captain', 'Completed', '2023-05-01'),
(6, 6, 3, 'First Officer', 'Completed', '2023-05-01'),
(7, 7, 4, 'Captain', 'Cancelled', '2023-05-01'),
(8, 8, 4, 'First Officer', 'Cancelled', '2023-05-01'),
(9, 9, 5, 'Captain', 'Completed', '2023-05-01'),
(10, 10, 5, 'First Officer', 'Completed', '2023-05-01'),
(11, 11, 6, 'Captain', 'Completed', '2023-05-01'),
(12, 12, 6, 'First Officer', 'Completed', '2023-05-01'),
(13, 13, 7, 'Captain', 'Completed', '2023-05-01'),
(14, 14, 7, 'First Officer', 'Completed', '2023-05-01'),
(15, 15, 8, 'Captain', 'Completed', '2023-05-02'),
(16, 16, 8, 'First Officer', 'Completed', '2023-05-02'),
(17, 17, 9, 'Captain', 'Completed', '2023-05-02'),
(18, 18, 9, 'First Officer', 'Completed', '2023-05-02'),
(19, 19, 10, 'Captain', 'Completed', '2023-05-02'),
(20, 20, 10, 'First Officer', 'Completed', '2023-05-02'),
(21, 21, 11, 'Captain', 'Completed', '2023-05-02'),
(22, 22, 11, 'First Officer', 'Completed', '2023-05-02'),
(23, 23, 12, 'Captain', 'Cancelled', '2023-05-02'),
(24, 24, 12, 'First Officer', 'Cancelled', '2023-05-02'),
(25, 25, 13, 'Captain', 'Completed', '2023-05-02'),
(26, 26, 13, 'First Officer', 'Completed', '2023-05-02'),
(27, 27, 14, 'Captain', 'Completed', '2023-05-02'),
(28, 28, 14, 'First Officer', 'Completed', '2023-05-02'),
(29, 29, 15, 'Captain', 'Completed', '2023-05-03'),
(30, 30, 15, 'First Officer', 'Completed', '2023-05-03');

-- PASSENGER table records
INSERT INTO customer.PASSENGER (passenger_id, f_name, L_name, m_name, date_of_birth, gender, email, phone_number, has_booking) VALUES 
(1, 'Emma', 'Johnson', 'A', '1985-03-12', 'F', 'emma.johnson@email.com', '555-0201', 1),
(2, 'Noah', 'Smith', 'B', '1990-07-25', 'M', 'noah.smith@email.com', '555-0202', 1),
(3, 'Olivia', 'Williams', 'C', '1988-11-18', 'F', 'olivia.williams@email.com', '555-0203', 1),
(4, 'Liam', 'Brown', 'D', '1992-05-30', 'M', 'liam.brown@email.com', '555-0204', 1),
(5, 'Ava', 'Jones', 'E', '1987-09-14', 'F', 'ava.jones@email.com', '555-0205', 1),
(6, 'William', 'Garcia', 'F', '1991-02-22', 'M', 'william.garcia@email.com', '555-0206', 1),
(7, 'Sophia', 'Miller', 'G', '1986-08-07', 'F', 'sophia.miller@email.com', '555-0207', 1),
(8, 'Benjamin', 'Davis', 'H', '1993-04-15', 'M', 'benjamin.davis@email.com', '555-0208', 1),
(9, 'Isabella', 'Rodriguez', 'I', '1989-12-03', 'F', 'isabella.rodriguez@email.com', '555-0209', 1),
(10, 'Mason', 'Martinez', 'J', '1994-06-28', 'M', 'mason.martinez@email.com', '555-0210', 1),
(11, 'Mia', 'Hernandez', 'K', '1984-10-11', 'F', 'mia.hernandez@email.com', '555-0211', 1),
(12, 'Elijah', 'Lopez', 'L', '1995-01-19', 'M', 'elijah.lopez@email.com', '555-0212', 1),
(13, 'Charlotte', 'Gonzalez', 'M', '1983-07-24', 'F', 'charlotte.gonzalez@email.com', '555-0213', 1),
(14, 'James', 'Wilson', 'N', '1996-03-08', 'M', 'james.wilson@email.com', '555-0214', 1),
(15, 'Amelia', 'Anderson', 'O', '1982-09-17', 'F', 'amelia.anderson@email.com', '555-0215', 1),
(16, 'Logan', 'Thomas', 'P', '1997-05-22', 'M', 'logan.thomas@email.com', '555-0216', 1),
(17, 'Harper', 'Taylor', 'Q', '1981-11-26', 'F', 'harper.taylor@email.com', '555-0217', 1),
(18, 'Lucas', 'Moore', 'R', '1998-08-13', 'M', 'lucas.moore@email.com', '555-0218', 1),
(19, 'Evelyn', 'Jackson', 'S', '1980-04-05', 'F', 'evelyn.jackson@email.com', '555-0219', 1),
(20, 'Alexander', 'Martin', 'T', '1999-02-09', 'M', 'alexander.martin@email.com', '555-0220', 1),
(21, 'Abigail', 'Lee', 'U', '1979-06-30', 'F', 'abigail.lee@email.com', '555-0221', 1),
(22, 'Michael', 'Perez', 'V', '2000-10-12', 'M', 'michael.perez@email.com', '555-0222', 1),
(23, 'Emily', 'Thompson', 'W', '1978-12-15', 'F', 'emily.thompson@email.com', '555-0223', 1),
(24, 'Daniel', 'White', 'X', '2001-07-23', 'M', 'daniel.white@email.com', '555-0224', 1),
(25, 'Elizabeth', 'Harris', 'Y', '1977-09-28', 'F', 'elizabeth.harris@email.com', '555-0225', 1),
(26, 'Matthew', 'Sanchez', 'Z', '2002-04-01', 'M', 'matthew.sanchez@email.com', '555-0226', 1),
(27, 'Sofia', 'Clark', 'AA', '1976-01-14', 'F', 'sofia.clark@email.com', '555-0227', 1),
(28, 'David', 'Ramirez', 'AB', '2003-08-19', 'M', 'david.ramirez@email.com', '555-0228', 1),
(29, 'Avery', 'Lewis', 'AC', '1975-03-27', 'F', 'avery.lewis@email.com', '555-0229', 1),
(30, 'Joseph', 'Robinson', 'AD', '2004-11-05', 'M', 'joseph.robinson@email.com', '555-0230', 1);

-- OCCASIONAL table records
INSERT INTO customer.OCCASIONAL (passenger_id, last_flight_date, total_flights_taken) VALUES 
(1, '2023-04-15', 3),
(2, '2023-03-22', 2),
(3, '2023-02-10', 1),
(4, '2023-01-18', 4),
(5, '2022-12-05', 2),
(6, '2022-11-30', 3),
(7, '2022-10-12', 1),
(8, '2022-09-25', 2),
(9, '2022-08-17', 3),
(10, '2022-07-14', 1),
(11, '2022-06-08', 5),
(12, '2022-05-19', 2),
(13, '2022-04-21', 3),
(14, '2022-03-15', 1),
(15, '2022-02-28', 4),
(16, '2022-01-11', 2),
(17, '2021-12-24', 3),
(18, '2021-11-05', 1),
(19, '2021-10-30', 2),
(20, '2021-09-12', 3),
(21, '2021-08-08', 1),
(22, '2021-07-19', 4),
(23, '2021-06-22', 2),
(24, '2021-05-14', 3),
(25, '2021-04-03', 1),
(26, '2021-03-27', 2),
(27, '2021-02-18', 3),
(28, '2021-01-09', 1),
(29, '2020-12-15', 4),
(30, '2020-11-20', 2);

-- FREQUENT_FLYER table records
INSERT INTO customer.FREQUENT_FLYER (passenger_id, join_date, membership_num, membership_level) VALUES 
(1, '2020-01-15', 'FF10001', 'Silver'),
(2, '2020-02-20', 'FF10002', 'Gold'),
(3, '2020-03-10', 'FF10003', 'Platinum'),
(4, '2020-04-05', 'FF10004', 'Silver'),
(5, '2020-05-12', 'FF10005', 'Gold'),
(6, '2020-06-18', 'FF10006', 'Platinum'),
(7, '2020-07-22', 'FF10007', 'Silver'),
(8, '2020-08-30', 'FF10008', 'Gold'),
(9, '2020-09-14', 'FF10009', 'Platinum'),
(10, '2020-10-25', 'FF10010', 'Silver'),
(11, '2020-11-05', 'FF10011', 'Gold'),
(12, '2020-12-10', 'FF10012', 'Platinum'),
(13, '2021-01-15', 'FF10013', 'Silver'),
(14, '2021-02-20', 'FF10014', 'Gold'),
(15, '2021-03-10', 'FF10015', 'Platinum'),
(16, '2021-04-05', 'FF10016', 'Silver'),
(17, '2021-05-12', 'FF10017', 'Gold'),
(18, '2021-06-18', 'FF10018', 'Platinum'),
(19, '2021-07-22', 'FF10019', 'Silver'),
(20, '2021-08-30', 'FF10020', 'Gold'),
(21, '2021-09-14', 'FF10021', 'Platinum'),
(22, '2021-10-25', 'FF10022', 'Silver'),
(23, '2021-11-05', 'FF10023', 'Gold'),
(24, '2021-12-10', 'FF10024', 'Platinum'),
(25, '2022-01-15', 'FF10025', 'Silver'),
(26, '2022-02-20', 'FF10026', 'Gold'),
(27, '2022-03-10', 'FF10027', 'Platinum'),
(28, '2022-04-05', 'FF10028', 'Silver'),
(29, '2022-05-12', 'FF10029', 'Gold'),
(30, '2022-06-18', 'FF10030', 'Platinum');

-- SEAT table records
INSERT INTO core.SEAT (seat_id, aircraft_id, seat_num, row_num, column_letter, class, is_reserved, reservation_date) VALUES 
(1, 1, '1A', 1, 'A', 'First', 1, '2023-04-25'),
(2, 1, '11B', 1, 'B', 'First', 1, '2023-04-25'),
(3, 1, '2A', 2, 'A', 'Business', 1, '2023-04-26'),
(4, 1, '2B', 2, 'B', 'Business', 1, '2023-04-26'),
(5, 1, '10C', 10, 'C', 'Economy', 1, '2023-04-27'),
(6, 1, '14D', 10, 'D', 'Economy', 1, '2023-04-27'),
(7, 2, '35A', 1, 'A', 'First', 1, '2023-04-28'),
(8, 2, '18B', 1, 'B', 'First', 1, '2023-04-28'),
(9, 2, '5C', 5, 'C', 'Business', 1, '2023-04-29'),
(10, 2, '5D', 5, 'D', 'Business', 1, '2023-04-29'),
(11, 2, '20E', 20, 'E', 'Economy', 1, '2023-04-30'),
(12, 2, '20F', 20, 'F', 'Economy', 1, '2023-04-30'),
(13, 3, '12A', 1, 'A', 'First', 1, '2023-05-01'),
(14, 3, '14B', 1, 'B', 'First', 1, '2023-05-01'),
(15, 3, '8C', 8, 'C', 'Business', 1, '2023-05-02'),
(16, 3, '8D', 8, 'D', 'Business', 1, '2023-05-02'),
(17, 3, '25E', 25, 'E', 'Economy', 1, '2023-05-03'),
(18, 3, '25F', 25, 'F', 'Economy', 1, '2023-05-03'),
(19, 4, '13A', 1, 'A', 'First', 1, '2023-05-04'),
(20, 4, '1B', 1, 'B', 'First', 1, '2023-05-04'),
(21, 4, '6C', 6, 'C', 'Business', 1, '2023-05-05'),
(22, 4, '6D', 6, 'D', 'Business', 1, '2023-05-05'),
(23, 4, '30E', 30, 'E', 'Economy', 1, '2023-05-06'),
(24, 4, '30F', 30, 'F', 'Economy', 1, '2023-05-06'),
(25, 5, '15A', 1, 'A', 'First', 1, '2023-05-07'),
(26, 5, '12B', 1, 'B', 'First', 1, '2023-05-07'),
(27, 5, '15C', 10, 'C', 'Business', 1, '2023-05-08'),
(28, 5, '10D', 10, 'D', 'Business', 1, '2023-05-08'),
(29, 5, '40E', 40, 'E', 'Economy', 1, '2023-05-09'),
(30, 5, '40F', 40, 'F', 'Economy', 1, '2023-05-09');

-- BOOKING table records
INSERT INTO customer.BOOKING (booking_id, passenger_id, flight_id, seat_id, date, status, type, device_type, agent_id, location) VALUES 
(1, 1, 1, 1, '2023-04-25 10:15:00', 'Confirmed', 'online', 'Mobile', NULL, 'New York'),
(2, 2, 1, 2, '2023-04-25 10:20:00', 'Confirmed', 'online', 'Desktop', NULL, 'Los Angeles'),
(3, 3, 2, 3, '2023-04-26 11:30:00', 'Confirmed', 'counter', NULL, 1, 'London'),
(4, 4, 2, 4, '2023-04-26 11:35:00', 'Confirmed', 'counter', NULL, 1, 'Paris'),
(5, 5, 3, 5, '2023-04-27 09:45:00', 'Confirmed', 'online', 'Mobile', NULL, 'Dubai'),
(6, 6, 3, 6, '2023-04-27 09:50:00', 'Confirmed', 'online', 'Desktop', NULL, 'Tokyo'),
(7, 7, 4, 7, '2023-04-28 14:20:00', 'Cancelled', 'online', 'Mobile', NULL, 'Sydney'),
(8, 8, 4, 8, '2023-04-28 14:25:00', 'Cancelled', 'online', 'Desktop', NULL, 'San Francisco'),
(9, 9, 5, 9, '2023-04-29 16:10:00', 'Confirmed', 'counter', NULL, 2, 'Chicago'),
(10, 10, 5, 10, '2023-04-29 16:15:00', 'Confirmed', 'counter', NULL, 2, 'Beijing'),
(11, 11, 6, 11, '2023-04-30 08:30:00', 'Confirmed', 'online', 'Mobile', NULL, 'Frankfurt'),
(12, 12, 6, 12, '2023-04-30 08:35:00', 'Confirmed', 'online', 'Desktop', NULL, 'Amsterdam'),
(13, 13, 7, 13, '2023-05-01 12:40:00', 'Confirmed', 'counter', NULL, 3, 'Seoul'),
(14, 14, 7, 14, '2023-05-01 12:45:00', 'Confirmed', 'counter', NULL, 3, 'Singapore'),
(15, 15, 8, 15, '2023-05-02 10:55:00', 'Confirmed', 'online', 'Mobile', NULL, 'Denver'),
(16, 16, 8, 16, '2023-05-02 11:00:00', 'Confirmed', 'online', 'Desktop', NULL, 'Bangkok'),
(17, 17, 9, 17, '2023-05-03 13:05:00', 'Confirmed', 'counter', NULL, 4, 'Madrid'),
(18, 18, 9, 18, '2023-05-03 13:10:00', 'Confirmed', 'counter', NULL, 4, 'Toronto'),
(19, 19, 10, 19, '2023-05-04 15:20:00', 'Confirmed', 'online', 'Mobile', NULL, 'Miami'),
(20, 20, 10, 20, '2023-05-04 15:25:00', 'Confirmed', 'online', 'Desktop', NULL, 'Istanbul'),
(21, 21, 11, 21, '2023-05-05 09:30:00', 'Confirmed', 'counter', NULL, 5, 'Munich'),
(22, 22, 11, 22, '2023-05-05 09:35:00', 'Confirmed', 'counter', NULL, 5, 'Hong Kong'),
(23, 23, 12, 23, '2023-05-06 11:40:00', 'Cancelled', 'online', 'Mobile', NULL, 'Kuala Lumpur'),
(24, 24, 12, 24, '2023-05-06 11:45:00', 'Cancelled', 'online', 'Desktop', NULL, 'São Paulo'),
(25, 25, 13, 25, '2023-05-07 14:50:00', 'Confirmed', 'counter', NULL, 6, 'Delhi'),
(26, 26, 13, 26, '2023-05-07 14:55:00', 'Confirmed', 'counter', NULL, 6, 'Copenhagen'),
(27, 27, 14, 27, '2023-05-08 16:00:00', 'Confirmed', 'online', 'Mobile', NULL, 'Atlanta'),
(28, 28, 14, 28, '2023-05-08 16:05:00', 'Confirmed', 'online', 'Desktop', NULL, 'Doha'),
(29, 29, 15, 29, '2023-05-09 18:10:00', 'Confirmed', 'counter', NULL, 7, 'Mexico City'),
(30, 30, 15, 30, '2023-05-09 18:15:00', 'Confirmed', 'counter', NULL, 7, 'Auckland');

-- PAYMENTtable records
INSERT INTO financial.PAYMENT (payment_id, booking_id, method, transaction_status, payment_amount, payment_date, payment_status) VALUES 
(1, 1, 'credit card', 'Completed', 1200.00, '2023-04-25 10:16:00', 'Paid'),
(2, 2, 'credit card', 'Completed', 1200.00, '2023-04-25 10:21:00', 'Paid'),
(3, 3, 'bank transfer', 'Completed', 950.00, '2023-04-26 11:31:00', 'Paid'),
(4, 4, 'bank transfer', 'Completed', 950.00, '2023-04-26 11:36:00', 'Paid'),
(5, 5, 'credit card', 'Completed', 750.00, '2023-04-27 09:46:00', 'Paid'),
(6, 6, 'credit card', 'Completed', 750.00, '2023-04-27 09:51:00', 'Paid'),
(7, 7, 'credit card', 'Refunded', 1800.00, '2023-04-28 14:21:00', 'Refunded'),
(8, 8, 'credit card', 'Refunded', 1800.00, '2023-04-28 14:26:00', 'Refunded'),
(9, 9, 'bank transfer', 'Completed', 850.00, '2023-04-29 16:11:00', 'Paid'),
(10, 10, 'bank transfer', 'Completed', 850.00, '2023-04-29 16:16:00', 'Paid'),
(11, 11, 'credit card', 'Completed', 650.00, '2023-04-30 08:31:00', 'Paid'),
(12, 12, 'credit card', 'Completed', 650.00, '2023-04-30 08:36:00', 'Paid'),
(13, 13, 'loyality points', 'Completed', 0.00, '2023-05-01 12:41:00', 'Paid'),
(14, 14, 'loyality points', 'Completed', 0.00, '2023-05-01 12:46:00', 'Paid'),
(15, 15, 'credit card', 'Completed', 550.00, '2023-05-02 10:56:00', 'Paid'),
(16, 16, 'credit card', 'Completed', 550.00, '2023-05-02 11:01:00', 'Paid'),
(17, 17, 'bank transfer', 'Completed', 1250.00, '2023-05-03 13:06:00', 'Paid'),
(18, 18, 'bank transfer', 'Completed', 1250.00, '2023-05-03 13:11:00', 'Paid'),
(19, 19, 'credit card', 'Completed', 950.00, '2023-05-04 15:21:00', 'Paid'),
(20, 20, 'credit card', 'Completed', 950.00, '2023-05-04 15:26:00', 'Paid'),
(21, 21, 'loyality points', 'Completed', 0.00, '2023-05-05 09:31:00', 'Paid'),
(22, 22, 'loyality points', 'Completed', 0.00, '2023-05-05 09:36:00', 'Paid'),
(23, 23, 'credit card', 'Refunded', 1100.00, '2023-05-06 11:41:00', 'Refunded'),
(24, 24, 'credit card', 'Refunded', 1100.00, '2023-05-06 11:46:00', 'Refunded'),
(25, 25, 'bank transfer', 'Completed', 850.00, '2023-05-07 14:51:00', 'Paid'),
(26, 26, 'bank transfer', 'Completed', 850.00, '2023-05-07 14:56:00', 'Paid'),
(27, 27, 'credit card', 'Completed', 750.00, '2023-05-08 16:01:00', 'Paid'),
(28, 28, 'credit card', 'Completed', 750.00, '2023-05-08 16:06:00', 'Paid'),
(29, 29, 'loyality points', 'Completed', 0.00, '2023-05-09 18:11:00', 'Paid'),
(30, 30, 'loyality points', 'Completed', 0.00, '2023-05-09 18:16:00', 'Paid');

-- CREDIT_CARD table records
INSERT INTO financial.CREDIT_CARD (payment_id, card_last_four_digits, type, authorization_code) VALUES 
(1, '1234', 'Visa', 'A1B2C3'),
(2, '2345', 'MasterCard', 'B2C3D4'),
(5, '3456', 'Visa', 'C3D4E5'),
(6, '4567', 'Amex', 'D4E5F6'),
(7, '5678', 'Visa', 'E5F6G7'),
(8, '6789', 'MasterCard', 'F6G7H8'),
(11, '7890', 'Visa', 'G7H8I9'),
(12, '8901', 'MasterCard', 'H8I9J0'),
(15, '9012', 'Visa', 'I9J0K1'),
(16, '0123', 'Amex', 'J0K1L2'),
(19, '1235', 'Visa', 'K1L2M3'),
(20, '2346', 'MasterCard', 'L2M3N4'),
(23, '3457', 'Visa', 'M3N4O5'),
(24, '4568', 'MasterCard', 'N4O5P6'),
(27, '5679', 'Visa', 'O5P6Q7'),
(28, '6780', 'Amex', 'P6Q7R8');

-- BANK_TRANSFER table records
INSERT INTO financial.BANK_TRANSFER (payment_id, bank_name, reference_number, acc_last_four_digits) VALUES 
(3, 'Chase', 'TRANS123456', '7890'),
(4, 'Bank of America', 'TRANS234567', '8901'),
(9, 'Wells Fargo', 'TRANS345678', '9012'),
(10, 'Citibank', 'TRANS456789', '0123'),
(17, 'HSBC', 'TRANS567890', '1234'),
(18, 'Barclays', 'TRANS678901', '2345'),
(25, 'Deutsche Bank', 'TRANS789012', '3456'),
(26, 'Santander', 'TRANS890123', '4567');

-- Insert 30 records into LOYALTY_POINTS
INSERT INTO financial.LOYALTY_POINTS (payment_id, points_redeemed, points_after_balance) VALUES 
(13, 25000, 5000),
(14, 25000, 5000),
(21, 30000, 10000),
(22, 30000, 10000),
(29, 35000, 15000),
(30, 35000, 15000);

-- Insert 30 records into BAGGAGE
INSERT INTO customer.BAGGAGE 
(baggage_id, passenger_id, booking_id, weight, status, type, security_scan_status, cabin_storage_location, fee) VALUES 
(1, 1, 1, 23.50, 'Checked', 'checked', 'Cleared', NULL, 30.00),
(2, 2, 2, 18.00, 'Checked', 'checked', 'Cleared', NULL, 25.00),
(3, 3, 3, 8.00, 'Carried', 'carry on', NULL, 'Overhead', 0.00),
(4, 4, 4, 7.50, 'Carried', 'carry on', NULL, 'Under seat', 0.00),
(5, 5, 5, 32.00, 'Checked', 'checked', 'Cleared', NULL, 50.00),
(6, 6, 6, 15.00, 'Checked', 'checked', 'Cleared', NULL, 20.00),
(7, 7, 7, 10.00, 'Carried', 'carry on', NULL, 'Overhead', 0.00),
(8, 8, 8, 27.00, 'Checked', 'checked', 'Cleared', NULL, 35.00),
(9, 9, 9, 5.00, 'Carried', 'carry on', NULL, 'Under seat', 0.00),
(10, 10, 10, 20.00, 'Checked', 'checked', 'Cleared', NULL, 28.00),
(11, 11, 11, 25.00, 'Checked', 'checked', 'Cleared', NULL, 32.00),
(12, 12, 12, 6.50, 'Carried', 'carry on', NULL, 'Overhead', 0.00),
(13, 13, 13, 9.00, 'Carried', 'carry on', NULL, 'Under seat', 0.00),
(14, 14, 14, 30.00, 'Checked', 'checked', 'Cleared', NULL, 45.00),
(15, 15, 15, 11.00, 'Checked', 'checked', 'Cleared', NULL, 22.00),
(16, 16, 16, 12.50, 'Checked', 'checked', 'Cleared', NULL, 24.00),
(17, 17, 17, 8.00, 'Carried', 'carry on', NULL, 'Overhead', 0.00),
(18, 18, 18, 7.00, 'Carried', 'carry on', NULL, 'Under seat', 0.00),
(19, 19, 19, 28.00, 'Checked', 'checked', 'Cleared', NULL, 38.00),
(20, 20, 20, 33.00, 'Checked', 'checked', 'Cleared', NULL, 55.00),
(21, 21, 21, 14.00, 'Checked', 'checked', 'Cleared', NULL, 20.00),
(22, 22, 22, 6.00, 'Carried', 'carry on', NULL, 'Overhead', 0.00),
(23, 23, 23, 9.50, 'Carried', 'carry on', NULL, 'Under seat', 0.00),
(24, 24, 24, 31.00, 'Checked', 'checked', 'Cleared', NULL, 48.00),
(25, 25, 25, 13.00, 'Checked', 'checked', 'Cleared', NULL, 26.00),
(26, 26, 26, 10.50, 'Checked', 'checked', 'Cleared', NULL, 21.00),
(27, 27, 27, 7.80, 'Carried', 'carry on', NULL, 'Overhead', 0.00),
(28, 28, 28, 6.20, 'Carried', 'carry on', NULL, 'Under seat', 0.00),
(29, 29, 29, 29.00, 'Checked', 'checked', 'Cleared', NULL, 40.00),
(30, 30, 30, 16.00, 'Checked', 'checked', 'Cleared', NULL, 26.00);

/*IMPLEMENTATION & QUERIES*/
-- Get origin and destination airports for flights operating on routes longer than the average route distance 
SELECT flight_id, flight_num,
(SELECT name FROM core.AIRPORT WHERE airport_id = 
(SELECT origin_airport_id FROM core.ROUTE WHERE route_id = f.route_id)) AS origin,
(SELECT name FROM core.AIRPORT WHERE airport_id = 
(SELECT destination_airport_id FROM core.ROUTE WHERE route_id = f.route_id)) AS destination
FROM core.FLIGHT f
WHERE f.route_id IN (SELECT route_id FROM core.ROUTE WHERE distance > (SELECT AVG(distance) FROM core.ROUTE));

-- Count flights by status
SELECT status, COUNT(flight_id) AS number_of_flights
FROM core.FLIGHT
GROUP BY status
HAVING COUNT(flight_id) > 2
ORDER BY number_of_flights ASC;

-- Get the payments where the total amount paid is $1000 or more and their count
SELECT method, COUNT(payment_id) AS number_of_payments, SUM(payment_amount) AS total_amount
FROM financial.PAYMENT
GROUP BY method
HAVING SUM(payment_amount) >= 1000
ORDER BY total_amount ASC;

-- View for flight schedule
CREATE VIEW core.Flight_Schedule AS
SELECT f.flight_id, f.flight_num, orig.name AS origin_airport, dest.name AS destination_airport, f.scheduled_departure_time, f.scheduled_arrival_time, a.model AS aircraft_model, f.status
FROM core.FLIGHT f
JOIN core.ROUTE r ON f.route_id = r.route_id
JOIN core.AIRPORT orig ON r.origin_airport_id = orig.airport_id
JOIN core.AIRPORT dest ON r.destination_airport_id = dest.airport_id
JOIN core.AIRCRAFT a ON f.aircraft_id = a.aircraft_id;
SELECT* FROM core.Flight_Schedule;

-- Static stored procedure: get aircrafts with an average distance greater than the average route distance
CREATE PROCEDURE core.Get_Flight_With_High_Avg_Distance
AS
BEGIN
	SELECT a.aircraft_id, a.model, AVG(r.distance) AS avg_route_distance
	FROM core.AIRCRAFT a
	JOIN core.FLIGHT f ON a.aircraft_id = f.aircraft_id
	JOIN core.ROUTE r ON f.route_id = r.route_id
	GROUP BY a.aircraft_id, a.model
	HAVING AVG(r.distance) > (SELECT AVG(distance) FROM core.ROUTE)
	ORDER BY avg_route_distance DESC;
END;
EXEC core.Get_Flight_With_High_Avg_Distance;

-- Dynamic stored procedure: get flights by status
CREATE PROCEDURE core.Get_Flight_By_Status (@status VARCHAR(20))
AS
BEGIN
	SELECT f.flight_id, f.flight_num, orig.name AS origin, dest.name AS destination, f.scheduled_departure_time, f.scheduled_arrival_time, f.status
	FROM core.FLIGHT f
	JOIN core.ROUTE r ON f.route_id = r.route_id
	JOIN core.AIRPORT orig ON r.origin_airport_id = orig.airport_id
	JOIN core.AIRPORT dest ON r.destination_airport_id = dest.airport_id
	WHERE f.status = @status
END;
EXEC core.Get_Flight_By_Status 'Delayed';

-- Trigger to update passenger has_booking status when a booking is made
CREATE TRIGGER customer.Update_Passenger_Booking_Status ON customer.BOOKING
AFTER INSERT
AS
BEGIN
    UPDATE customer.PASSENGER
    SET has_booking = 1
    WHERE passenger_id IN (SELECT passenger_id FROM inserted);
END;

-- Trigger to free seats when a booking is cancelled
CREATE TRIGGER customer.Free_Seat_On_Cancellation ON customer.BOOKING
AFTER DELETE
AS
BEGIN
    UPDATE core.SEAT
    SET is_reserved = 0, reservation_date = NULL
    WHERE seat_id IN (SELECT seat_id FROM deleted);
END;
