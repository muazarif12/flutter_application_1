--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

-- Started on 2025-04-15 13:20:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 224 (class 1259 OID 16437)
-- Name: arena_slots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arena_slots (
    id integer NOT NULL,
    arena_id integer,
    day_of_week character varying(10) NOT NULL,
    start_time time without time zone NOT NULL,
    end_time time without time zone NOT NULL,
    duration integer NOT NULL,
    is_booked boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.arena_slots OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16436)
-- Name: arena_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.arena_slots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.arena_slots_id_seq OWNER TO postgres;

--
-- TOC entry 4843 (class 0 OID 0)
-- Dependencies: 223
-- Name: arena_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.arena_slots_id_seq OWNED BY public.arena_slots.id;


--
-- TOC entry 220 (class 1259 OID 16407)
-- Name: arenas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arenas (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    sport_offered character varying(100),
    location character varying(255),
    contact_number character varying(15),
    pricing numeric(10,2),
    additional_fee numeric(10,2),
    owner_id integer,
    facilities text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.arenas OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16406)
-- Name: arenas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.arenas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.arenas_id_seq OWNER TO postgres;

--
-- TOC entry 4844 (class 0 OID 0)
-- Dependencies: 219
-- Name: arenas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.arenas_id_seq OWNED BY public.arenas.id;


--
-- TOC entry 222 (class 1259 OID 16422)
-- Name: media; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.media (
    id integer NOT NULL,
    arena_id integer,
    media_type character varying(50),
    file_path text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.media OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16421)
-- Name: media_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.media_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.media_id_seq OWNER TO postgres;

--
-- TOC entry 4845 (class 0 OID 0)
-- Dependencies: 221
-- Name: media_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.media_id_seq OWNED BY public.media.id;


--
-- TOC entry 218 (class 1259 OID 16390)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255),
    full_name character varying(255),
    phone_number character varying(15),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    role character varying(50) DEFAULT 'user'::character varying,
    google_id character varying(255),
    facebook_id character varying(255)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16389)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4846 (class 0 OID 0)
-- Dependencies: 217
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4663 (class 2604 OID 16440)
-- Name: arena_slots id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arena_slots ALTER COLUMN id SET DEFAULT nextval('public.arena_slots_id_seq'::regclass);


--
-- TOC entry 4659 (class 2604 OID 16410)
-- Name: arenas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arenas ALTER COLUMN id SET DEFAULT nextval('public.arenas_id_seq'::regclass);


--
-- TOC entry 4661 (class 2604 OID 16425)
-- Name: media id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media ALTER COLUMN id SET DEFAULT nextval('public.media_id_seq'::regclass);


--
-- TOC entry 4656 (class 2604 OID 16393)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4837 (class 0 OID 16437)
-- Dependencies: 224
-- Data for Name: arena_slots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.arena_slots (id, arena_id, day_of_week, start_time, end_time, duration, is_booked, created_at) FROM stdin;
\.


--
-- TOC entry 4833 (class 0 OID 16407)
-- Dependencies: 220
-- Data for Name: arenas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.arenas (id, name, description, sport_offered, location, contact_number, pricing, additional_fee, owner_id, facilities, created_at) FROM stdin;
\.


--
-- TOC entry 4835 (class 0 OID 16422)
-- Dependencies: 222
-- Data for Name: media; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.media (id, arena_id, media_type, file_path, created_at) FROM stdin;
\.


--
-- TOC entry 4831 (class 0 OID 16390)
-- Dependencies: 218
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password, full_name, phone_number, created_at, role, google_id, facebook_id) FROM stdin;
1	imtiaz123	imtiaz@example.com	$2b$10$QyC4FTDnJhXRPUIf44puiONPmWTr7qYgXPYfDfPc21Ddsizhn3ktC	Imtiaz Arif	03001234567	2025-04-07 17:24:54.315443	user	\N	\N
2	mt4	muaz13@gmail.com	$2b$10$XcFcX9p2Z34Nuz47HGBI3eeCa/4B60qUpcDXpCfs82TOdlfSJcg72	muaz	80780780	2025-04-07 18:07:57.441637	user	\N	\N
3	mar3lg	marlon@mail.com	$2b$10$hdZSC4Bsf0t3Iog8Z2mcx.fu/ENyIR7JDkSJyZFB8LhBhqWzzPQ0u	marlon	1234567890	2025-04-07 18:14:33.364222	user	\N	\N
5	admin	admin@mail.com	$2b$10$V6ORzV7cvA7nTkTAdJWyoOgMfRYRDlpQk6CSXliAwbMRTBb1gSeQy	System Admin	00000000000	2025-04-07 19:37:56.982179	admin	\N	\N
4	iffi	q@mail.com	$2b$10$Gp.9KCD37E5lPc.8.Gri0e7ZpfUKRhqWxw8s3O84K69.d83wT.dMO	qamar	14224124	2025-04-07 18:34:46.16729	admin	\N	\N
6	host_01	host01@mail.com	$2b$10$MYS8.4ub2DREXYbvWBfoU.VxwCOYFjPkROpfVMhuRVmQvHFrKc95m	Host One	03001234567	2025-04-07 19:56:48.176059	host	\N	\N
7	host4	host4@gmail.com	$2b$10$NT6Tpid.8o0XcuRzboZF0uIy.IQBF7NwOz/M5WjXZjJSDhU8annHO	host4	23523523	2025-04-12 18:46:48.769877	user	\N	\N
8	m145	m@gmail.com	$2b$10$UFFQr4bGUhUtq.goE.GUFeSP9kKH/R5zKsVGrhelx2AM1N4jOoDHu	m145	123	2025-04-13 15:55:47.440139	user	\N	\N
9	ht	ht@mail.com	$2b$10$ZnJwRj1Uee2TEJfmnvPhD.XlIcBny.5DlXbcdZb9kK5lULCxDKHlS	Host One	03001234567	2025-04-13 15:59:36.215414	host	\N	\N
\.


--
-- TOC entry 4847 (class 0 OID 0)
-- Dependencies: 223
-- Name: arena_slots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.arena_slots_id_seq', 1, false);


--
-- TOC entry 4848 (class 0 OID 0)
-- Dependencies: 219
-- Name: arenas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.arenas_id_seq', 1, false);


--
-- TOC entry 4849 (class 0 OID 0)
-- Dependencies: 221
-- Name: media_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.media_id_seq', 1, false);


--
-- TOC entry 4850 (class 0 OID 0)
-- Dependencies: 217
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 9, true);


--
-- TOC entry 4679 (class 2606 OID 16444)
-- Name: arena_slots arena_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arena_slots
    ADD CONSTRAINT arena_slots_pkey PRIMARY KEY (id);


--
-- TOC entry 4675 (class 2606 OID 16415)
-- Name: arenas arenas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arenas
    ADD CONSTRAINT arenas_pkey PRIMARY KEY (id);


--
-- TOC entry 4677 (class 2606 OID 16430)
-- Name: media media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);


--
-- TOC entry 4667 (class 2606 OID 16405)
-- Name: users unique_email; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT unique_email UNIQUE (email);


--
-- TOC entry 4681 (class 2606 OID 16446)
-- Name: arena_slots unique_slot_per_day; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arena_slots
    ADD CONSTRAINT unique_slot_per_day UNIQUE (arena_id, day_of_week, start_time, end_time);


--
-- TOC entry 4669 (class 2606 OID 16402)
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- TOC entry 4671 (class 2606 OID 16398)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4673 (class 2606 OID 16400)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4684 (class 2606 OID 16447)
-- Name: arena_slots arena_slots_arena_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arena_slots
    ADD CONSTRAINT arena_slots_arena_id_fkey FOREIGN KEY (arena_id) REFERENCES public.arenas(id) ON DELETE CASCADE;


--
-- TOC entry 4682 (class 2606 OID 16416)
-- Name: arenas arenas_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arenas
    ADD CONSTRAINT arenas_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4683 (class 2606 OID 16431)
-- Name: media media_arena_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.media
    ADD CONSTRAINT media_arena_id_fkey FOREIGN KEY (arena_id) REFERENCES public.arenas(id) ON DELETE CASCADE;


-- Completed on 2025-04-15 13:20:16

--
-- PostgreSQL database dump complete
--

