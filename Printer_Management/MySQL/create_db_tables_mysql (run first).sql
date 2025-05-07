CREATE DATABASE CNPM;
USE CNPM;

-- DROP DATABASE CNPM;  

--
-- Table structure for table file_formats
--

CREATE TABLE file_formats(
	id TINYINT  NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(10) NOT NULL UNIQUE
);

--
-- Table structure for table roles
--

CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

--
-- Table structure for table students
--

CREATE TABLE students(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	full_name VARCHAR(255) NOT NULL,
	email VARCHAR(255) NOT NULL UNIQUE,
	join_date DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
	last_login DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
	student_balance INT NOT NULL CHECK (student_balance >= 0) DEFAULT 0,
    role_id BIGINT,
    password VARCHAR(255),
    image_url VARCHAR(255),
    CONSTRAINT student_role_id_fk FOREIGN KEY (role_id) REFERENCES roles (id) 
);

--
-- Table structure for table files
--

CREATE TABLE files(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	size DECIMAL(10,2) NOT NULL,
	file_format_id TINYINT NOT NULL,
	upload_date DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    url TEXT NOT NULL,
    student_id INT NOT NULL,
	CONSTRAINT file_file_format_id_fk FOREIGN KEY (file_format_id) REFERENCES file_formats(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT file_student_id FOREIGN KEY (student_id) REFERENCES students (id)
		ON DELETE CASCADE
        ON UPDATE CASCADE
);

--
-- Table structure for table spso
--

CREATE TABLE spso(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	username VARCHAR(255) NOT NULL UNIQUE,
	password VARCHAR(255) NOT NULL,
	role_id BIGINT,
	email VARCHAR(255) NOT NULL UNIQUE,
	phone_number CHAR(10), -- XXXXXXXXXX
	birthdate DATE,
	join_date DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
    CONSTRAINT spso_role_id_fk FOREIGN KEY (role_id) REFERENCES roles (id)
);

--
-- Table structure for table page_allocations
--

CREATE Table page_allocations(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	semester TINYINT NOT NULL CHECK (semester IN (1, 2, 3)),
	year SMALLINT NOT NULL,
	number_of_pages INT NOT NULL CHECK (number_of_pages > 0),
	date DATE NOT NULL,
	status VARCHAR(15) NOT NULL CHECK (status IN ('pending', 'allocated')) DEFAULT 'pending',
	spso_id INT,
	CONSTRAINT page_allocation_spso_id_fk FOREIGN KEY (spso_id) REFERENCES spso (id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
);

--
-- Table structure for table reports
--

CREATE TABLE reports(
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    spso_id INT,
    paper_purchase_count INT NOT NULL CHECK (paper_purchase_count >= 0), -- Số lượt mua giấy
    paper_sold_count INT NOT NULL CHECK (paper_sold_count >= 0),         -- Số giấy đã bán
    revenue_from_paper_sales INT NOT NULL CHECK (revenue_from_paper_sales >= 0), -- Tiền kiếm được từ việc bán giấy
    printed_a4_pages INT NOT NULL CHECK (printed_a4_pages >= 0),         -- Số tờ A4 đã in
    printed_a3_pages INT NOT NULL CHECK (printed_a3_pages >= 0),         -- Số tờ A3 đã in
    print_job_count INT NOT NULL CHECK (print_job_count >= 0),           -- Số lần in
    start_date DATE,                                                    -- Thời gian bắt đầu
    end_date DATE,                                                      -- Thời gian kết thúc
    type VARCHAR(10) NOT NULL CHECK(type IN ('monthly', 'yearly')) DEFAULT 'monthly',
    CONSTRAINT report_spso_id_fk FOREIGN KEY (spso_id) REFERENCES spso (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

--
-- Table structure for table locations
--

CREATE TABLE locations(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name VARCHAR(10) NOT NULL,
	campus CHAR(3) NOT NULL CHECK (campus IN ('cs1', 'cs2')),
	floor TINYINT NOT NULL,
	room_number SMALLINT NOT NULL,
    CONSTRAINT unique_location UNIQUE (name, campus, floor, room_number)
);

--
-- Table structure for table printers
--

CREATE TABLE printers(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	location_id INT,
	spso_id INT,
	name VARCHAR(255) NOT NULL,
	brand VARCHAR(50) NOT NULL,
	type VARCHAR(50) NOT NULL,
	description VARCHAR(255),
    a4_remaining_pages INT NOT NULL CHECK (a4_remaining_pages >= 0),
    a3_remaining_pages INT NOT NULL CHECK (a3_remaining_pages >= 0),
	support_contact CHAR(10),
	last_maintenance_date DATETIME DEFAULT (CURRENT_TIMESTAMP),
	status VARCHAR(10) CHECK (status IN ('active', 'inactive', 'occupied','deleted')) DEFAULT 'active',
	CONSTRAINT printer_location_id_fk FOREIGN KEY (location_id) REFERENCES locations (id),
	CONSTRAINT printer_spso_id_fk FOREIGN KEY (spso_id) REFERENCES spso (id)
		ON UPDATE CASCADE
);

--
-- Table structure for table payments
--

CREATE TABLE payments(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	student_id INT NOT NULL,
    balance INT NOT NULL CHECK (balance > 0),
	amount INT NOT NULL CHECK (amount > 0),
	method VARCHAR(20) NOT NULL DEFAULT 'MoMo',
	transaction_date DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
	status VARCHAR(15) NOT NULL CHECK (status IN ('in progress', 'successful', 'failed')) DEFAULT 'in progress',
    order_id VARCHAR(255) NOT NULL UNIQUE,
    request_id VARCHAR(255) NOT NULL UNIQUE, 
	CONSTRAINT payment_student_id_fk FOREIGN KEY (student_id) REFERENCES students (id)
);

--
-- Table structure for tables print_jobs
--

CREATE TABLE print_jobs(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	student_id INT NOT NULL,
	file_id INT,
	number_of_copies INT NOT NULL CHECK (number_of_copies > 0),
	page_number TEXT NOT NULL,
	page_side VARCHAR(25) NOT NULL CHECK (page_side IN ('one sided', 'double sided')) DEFAULT 'one sided',
	page_size CHAR(2) CHECK (page_size IN ('A4', 'A3')),
	page_scale INT NOT NULL CHECK (page_scale > 0) DEFAULT 100,
	color_mode BOOL NOT NULL DEFAULT FALSE,
	submission_time DATETIME,
	completion_time DATETIME,
	status VARCHAR(15) NOT NULL CHECK (status IN ('in progress', 'successful', 'failed')) DEFAULT 'in progress',
	date DATETIME DEFAULT (CURRENT_TIMESTAMP),
	total_page INT CHECK (total_page > 0),
	total_cost INT CHECK (total_cost > 0),
	printer_id INT,
    is_duplex TINYINT(1) default 0,
	CONSTRAINT print_job_student_id_fk FOREIGN KEY (student_id) REFERENCES students (id),
	CONSTRAINT print_job_file_id_fk FOREIGN KEY (file_id) REFERENCES files (id)
		ON DELETE SET NULL,
	CONSTRAINT print_job_printer_fk FOREIGN KEY (printer_id) REFERENCES printers (id)
		ON DELETE SET NULL
);

--
-- Table structure for table tokens
--

-- CREATE TABLE tokens (
--     id BIGINT AUTO_INCREMENT PRIMARY KEY,
--     token VARCHAR(255) NOT NULL,  -- Access token hoặc refresh token
--     token_type VARCHAR(50) NOT NULL,  -- Loại token (access hoặc refresh)
--     student_id INT NOT NULL,  -- ID của sinh viên sở hữu token
--     issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Thời điểm token được cấp
--     expires_at TIMESTAMP,  -- Thời điểm token hết hạn
--     revoked BOOLEAN DEFAULT FALSE,  -- Trạng thái thu hồi token
--     device_info VARCHAR(255),  -- Thông tin thiết bị đăng nhập
--     ip_address VARCHAR(45),  -- Địa chỉ IP đăng nhập
--     is_mobile TINYINT(1) DEFAULT 0,  -- Trạng thái đăng nhập trên thiết bị di động
--     refresh_token VARCHAR(255) NOT NULL,  -- Refresh token
--     refresh_expiration_date TIMESTAMP,  -- Thời gian hết hạn refresh token
--     role VARCHAR(50),
--     FOREIGN KEY (student_id) REFERENCES students(id)  -- Liên kết với bảng students
-- );
