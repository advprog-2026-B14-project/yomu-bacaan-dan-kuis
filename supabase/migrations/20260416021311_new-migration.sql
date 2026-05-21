create table if not exists learning_mod.quiz_attempts (
	id serial primary key,
	student_id varchar(255) not null,
	reading_id integer not null,
	status varchar(20) not null,
	started_at timestamp not null,
	completed_at timestamp,
	score integer,
	constraint fk_quiz_attempts_reading
		foreign key (reading_id)
		references learning_mod.readings (id)
		on delete cascade
);

create index if not exists idx_quiz_attempts_student_reading
	on learning_mod.quiz_attempts (student_id, reading_id);
