```sql

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS users_user_id_seq;

-- Table Definition
CREATE TABLE "public"."users" (
    "user_id" int4 NOT NULL DEFAULT nextval('users_user_id_seq'::regclass),
    "user_email" varchar(500),
    "user_role" text,
    PRIMARY KEY ("user_id")
);


GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO subscription;
```
