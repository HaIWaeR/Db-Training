CREATE TABLE weapon (
    id SERIAL PRIMARY KEY,
    number_weapon VARCHAR(50) NOT NULL UNIQUE,
    type_weapon VARCHAR(100) NOT NULL
);

CREATE TABLE department (
	id SERIAL PRIMARY KEY,
	name_department VARCHAR(50) NOT NULL,
	cheif_id INT
);

CREATE TABLE job_title (
	id SERIAL PRIMARY KEY,
	name_job_title VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE ranks(
	id SERIAL PRIMARY KEY,
	name_ranks VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE employee(
	id SERIAL PRIMARY KEY,
	personnel_number VARCHAR(20) UNIQUE,
    case_number VARCHAR(20) UNIQUE,   
	personnel_phone VARCHAR(20) NOT NULL,
	passport_details VARCHAR(30) NOT NULL UNIQUE,
	SNILS VARCHAR(14) NOT NULL UNIQUE,
	INN VARCHAR(12) NOT NULL UNIQUE,
	policy_OMS VARCHAR(16) NOT NULL UNIQUE,
	military_id_details VARCHAR(50) NOT NULL,
	date_of_admission_to_service DATE NOT NULL,
	schedule_work TEXT,

	ranks_id INT NOT NULL,
    department_id INT NOT NULL,
    job_title_id INT NOT NULL,
    weapon_id INT,

	CONSTRAINT fk_employee_rank FOREIGN KEY (ranks_id) REFERENCES ranks(id),
	CONSTRAINT fk_employee_department FOREIGN KEY (department_id) REFERENCES department(id),
	CONSTRAINT fk_employee_job_title FOREIGN KEY (job_title_id) REFERENCES job_title(id),
	CONSTRAINT fk_employee_weapon FOREIGN KEY (weapon_id) REFERENCES weapon(id)
);


CREATE TABLE citizen (
	id SERIAL PRIMARY KEY,
    passport_details VARCHAR(100) NOT NULL UNIQUE,
    contact_phone VARCHAR(20) NOT NULL,
    residential_address TEXT NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TYPE appeal_status AS ENUM (
    'Открытое', 
    'В рассмотрении', 
    'Закрыто'
);

CREATE TABLE appeal(
	id SERIAL PRIMARY KEY,
	number_appeal VARCHAR(20) NOT NULL UNIQUE,
	datetime_registration TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	status appeal_status NOT NULL DEFAULT 'Открытое',

	citizen_id INT NOT NULL,
	employee_id INT NOT NULL,

	CONSTRAINT fk_appeal_citizen FOREIGN KEY (citizen_id) REFERENCES citizen(id),
	CONSTRAINT fk_appeal_employee FOREIGN KEY (employee_id) REFERENCES employee(id)
);

CREATE TABLE act (
	id SERIAL PRIMARY KEY,
	number_act VARCHAR(20) NOT NULL UNIQUE,
	datetime_investigation TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	the_facts_revealed TEXT,
	date_completion_investigation DATE NOT NULL DEFAULT CURRENT_DATE,

	appeal_id INT NOT NULL,

	CONSTRAINT fk_act_appeal FOREIGN KEY (appeal_id) REFERENCES appeal(id)
);

CREATE TABLE article(
	id SERIAL PRIMARY KEY,
	number_article VARCHAR(20) NOT NULL UNIQUE,
	name_article VARCHAR(200) NOT NULL,
	article_type VARCHAR(50) NOT NULL 
);

CREATE TABLE appeal_article(
	id SERIAL PRIMARY KEY,
	
	appeal_id INT NOT NULL,
	article_id INT NOT NULL,
	
	CONSTRAINT fk_appeal_article_appeal FOREIGN KEY (appeal_id) REFERENCES appeal(id),
	CONSTRAINT fk_appeal_article_article FOREIGN KEY (article_id) REFERENCES article(id) 
);

CREATE TABLE diplom (
	id SERIAL PRIMARY KEY,
	series_and_number_diplom VARCHAR(30) NOT NULL UNIQUE,
	speciality VARCHAR(50) NOT NULL,
	educational_institution VARCHAR(100) NOT NULL,
	year_of_graduation DATE NOT NULL,

	employee_id INT NOT NULL,

	CONSTRAINT fk_diplom_employee FOREIGN KEY (employee_id) REFERENCES employee(id)
);



