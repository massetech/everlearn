--
-- PostgreSQL database dump
--

-- Dumped from database version 10.0
-- Dumped by pg_dump version 10.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cards (
    id bigint NOT NULL,
    language character varying(255),
    title character varying(255),
    active boolean DEFAULT false NOT NULL,
    item_id bigint,
    language_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cards_id_seq OWNED BY cards.id;


--
-- Name: classrooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE classrooms (
    id bigint NOT NULL,
    title character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: classrooms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE classrooms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: classrooms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE classrooms_id_seq OWNED BY classrooms.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE items (
    id bigint NOT NULL,
    "group" character varying(255),
    title character varying(255),
    level integer,
    description character varying(255),
    active boolean DEFAULT false NOT NULL,
    topic_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE items_id_seq OWNED BY items.id;


--
-- Name: languages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE languages (
    id bigint NOT NULL,
    name character varying(255),
    flag character varying(255),
    iso2code character varying(255),
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: languages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE languages_id_seq OWNED BY languages.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE memberships (
    id bigint NOT NULL,
    user_id bigint,
    pack_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memberships_id_seq OWNED BY memberships.id;


--
-- Name: packitems; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE packitems (
    id bigint NOT NULL,
    pack_id bigint,
    item_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: packitems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE packitems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: packitems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE packitems_id_seq OWNED BY packitems.id;


--
-- Name: packs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE packs (
    id bigint NOT NULL,
    title character varying(255),
    description character varying(255),
    level integer,
    active boolean DEFAULT false NOT NULL,
    classroom_id bigint,
    language_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: packs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE packs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: packs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE packs_id_seq OWNED BY packs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp without time zone
);


--
-- Name: topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE topics (
    id bigint NOT NULL,
    title character varying(255),
    classroom_id bigint,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE topics_id_seq OWNED BY topics.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id bigint NOT NULL,
    uid character varying(255),
    email character varying(255),
    name character varying(255),
    nickname character varying(255),
    role character varying(255),
    main_language character varying(255),
    provider character varying(255),
    token character varying(255),
    token_expiration timestamp without time zone,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards ALTER COLUMN id SET DEFAULT nextval('cards_id_seq'::regclass);


--
-- Name: classrooms id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY classrooms ALTER COLUMN id SET DEFAULT nextval('classrooms_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY items ALTER COLUMN id SET DEFAULT nextval('items_id_seq'::regclass);


--
-- Name: languages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY languages ALTER COLUMN id SET DEFAULT nextval('languages_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: packitems id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY packitems ALTER COLUMN id SET DEFAULT nextval('packitems_id_seq'::regclass);


--
-- Name: packs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY packs ALTER COLUMN id SET DEFAULT nextval('packs_id_seq'::regclass);


--
-- Name: topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics ALTER COLUMN id SET DEFAULT nextval('topics_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: classrooms classrooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY classrooms
    ADD CONSTRAINT classrooms_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: packitems packitems_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY packitems
    ADD CONSTRAINT packitems_pkey PRIMARY KEY (id);


--
-- Name: packs packs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY packs
    ADD CONSTRAINT packs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: cards_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX cards_item_id_index ON cards USING btree (item_id);


--
-- Name: items_topic_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX items_topic_id_index ON items USING btree (topic_id);


--
-- Name: memberships_pack_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX memberships_pack_id_index ON memberships USING btree (pack_id);


--
-- Name: memberships_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX memberships_user_id_index ON memberships USING btree (user_id);


--
-- Name: packitems_item_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX packitems_item_id_index ON packitems USING btree (item_id);


--
-- Name: packitems_pack_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX packitems_pack_id_index ON packitems USING btree (pack_id);


--
-- Name: packs_classroom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX packs_classroom_id_index ON packs USING btree (classroom_id);


--
-- Name: packs_language_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX packs_language_id_index ON packs USING btree (language_id);


--
-- Name: topics_classroom_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX topics_classroom_id_index ON topics USING btree (classroom_id);


--
-- Name: cards cards_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_item_id_fkey FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE;


--
-- Name: cards cards_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: items items_topic_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY items
    ADD CONSTRAINT items_topic_id_fkey FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE;


--
-- Name: memberships memberships_pack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pack_id_fkey FOREIGN KEY (pack_id) REFERENCES packs(id) ON DELETE CASCADE;


--
-- Name: memberships memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: packitems packitems_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY packitems
    ADD CONSTRAINT packitems_item_id_fkey FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE;


--
-- Name: packitems packitems_pack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY packitems
    ADD CONSTRAINT packitems_pack_id_fkey FOREIGN KEY (pack_id) REFERENCES packs(id) ON DELETE CASCADE;


--
-- Name: packs packs_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY packs
    ADD CONSTRAINT packs_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE CASCADE;


--
-- Name: packs packs_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY packs
    ADD CONSTRAINT packs_language_id_fkey FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE;


--
-- Name: topics topics_classroom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY topics
    ADD CONSTRAINT topics_classroom_id_fkey FOREIGN KEY (classroom_id) REFERENCES classrooms(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

INSERT INTO "schema_migrations" (version) VALUES (20171010163141), (20171011175608), (20171011184128), (20171011184211), (20171011184220), (20171011184526), (20171011184656), (20171011185035), (20171011185141);

