--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10
-- Dumped by pg_dump version 15.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: orderstatus; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.orderstatus AS ENUM (
    'PENDING',
    'PROCESSING',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED',
    'BACKORDERED'
);


ALTER TYPE public.orderstatus OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_items (
    id integer NOT NULL,
    cart_id integer,
    product_id integer,
    quantity integer,
    added_at timestamp without time zone
);


ALTER TABLE public.cart_items OWNER TO postgres;

--
-- Name: cart_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cart_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cart_items_id_seq OWNER TO postgres;

--
-- Name: cart_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cart_items_id_seq OWNED BY public.cart_items.id;


--
-- Name: carts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carts (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.carts OWNER TO postgres;

--
-- Name: carts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.carts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.carts_id_seq OWNER TO postgres;

--
-- Name: carts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.carts_id_seq OWNED BY public.carts.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.companies (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    contact_email character varying(100) NOT NULL,
    contact_phone character varying(20) NOT NULL,
    website character varying(100)
);


ALTER TABLE public.companies OWNER TO postgres;

--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.companies_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.companies_id_seq OWNER TO postgres;

--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: conversations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.conversations (
    id integer NOT NULL,
    user_id integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    duration integer
);


ALTER TABLE public.conversations OWNER TO postgres;

--
-- Name: conversations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.conversations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.conversations_id_seq OWNER TO postgres;

--
-- Name: conversations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.conversations_id_seq OWNED BY public.conversations.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    id integer NOT NULL,
    sender_id character varying(255) NOT NULL,
    type_name character varying(255) NOT NULL,
    "timestamp" double precision,
    intent_name character varying(255),
    action_name character varying(255),
    data text
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    conversation_id integer,
    is_user boolean,
    content text NOT NULL,
    "timestamp" timestamp without time zone
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_id_seq OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer,
    product_name character varying(100) NOT NULL,
    quantity integer NOT NULL,
    price double precision NOT NULL
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_items_id_seq OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    order_number character varying(20) NOT NULL,
    user_id integer,
    total_amount double precision NOT NULL,
    status public.orderstatus,
    ordered_at timestamp without time zone,
    estimated_delivery timestamp without time zone,
    delivered_at timestamp without time zone,
    shipping_address text NOT NULL,
    tracking_number character varying(50)
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id integer NOT NULL,
    company_id integer,
    name character varying(100) NOT NULL,
    description text,
    price double precision NOT NULL,
    stock_quantity integer,
    image_url character varying(255),
    category character varying(50),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO postgres;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: support_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.support_data (
    id integer NOT NULL,
    company_id integer,
    question text NOT NULL,
    answer text NOT NULL,
    category character varying(50) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.support_data OWNER TO postgres;

--
-- Name: support_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.support_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.support_data_id_seq OWNER TO postgres;

--
-- Name: support_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.support_data_id_seq OWNED BY public.support_data.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password_hash character varying(128) NOT NULL,
    created_at timestamp without time zone,
    last_login timestamp without time zone,
    is_active boolean
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: cart_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN id SET DEFAULT nextval('public.cart_items_id_seq'::regclass);


--
-- Name: carts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts ALTER COLUMN id SET DEFAULT nextval('public.carts_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: conversations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations ALTER COLUMN id SET DEFAULT nextval('public.conversations_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: support_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_data ALTER COLUMN id SET DEFAULT nextval('public.support_data_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_items (id, cart_id, product_id, quantity, added_at) FROM stdin;
\.


--
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.carts (id, user_id, created_at, updated_at) FROM stdin;
1	4	2025-04-19 12:51:07.625498	2025-04-19 12:59:20.934074
2	5	2025-04-19 14:53:09.534599	2025-04-19 14:53:09.534599
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.companies (id, name, description, contact_email, contact_phone, website) FROM stdin;
1	AI Chat Support Inc.	Leading provider of AI-powered chatbot solutions	support@aichatsupport.com	1-800-CHATBOT	https://aichatsupport.example.com
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.conversations (id, user_id, start_time, end_time, duration) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.events (id, sender_id, type_name, "timestamp", intent_name, action_name, data) FROM stdin;
1	4	action	1745044393.202479	\N	action_session_start	{"event": "action", "timestamp": 1745044393.202479, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_session_start", "policy": null, "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
2	4	session_started	1745044393.202479	\N	\N	{"event": "session_started", "timestamp": 1745044393.202479, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}}
3	4	action	1745044393.202479	\N	action_listen	{"event": "action", "timestamp": 1745044393.202479, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": null, "confidence": null, "action_text": null, "hide_rule_turn": false}
4	4	user	1745044394.1430557	greet	\N	{"event": "user", "timestamp": 1745044394.1430557, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "hi", "parse_data": {"intent": {"name": "greet", "confidence": 0.9954788088798523}, "entities": [], "text": "hi", "message_id": "b2aa1fadf4f84f9fa9f39a8fd405ee49", "metadata": {}, "text_tokens": [[0, 2]], "intent_ranking": [{"name": "greet", "confidence": 0.9954788088798523}, {"name": "ask_order_status", "confidence": 0.0014418027130886912}, {"name": "deny", "confidence": 0.00049217464402318}, {"name": "out_of_scope", "confidence": 0.00041197490645572543}, {"name": "ask_track_order", "confidence": 0.000279021478490904}, {"name": "ask_shipping_time", "confidence": 0.00025088488473556936}, {"name": "ask_payment_methods", "confidence": 0.00023734100977890193}, {"name": "affirm", "confidence": 0.00023431364388670772}, {"name": "ask_return_policy", "confidence": 0.00023091623734217137}, {"name": "ask_international_shipping", "confidence": 0.00022463045024778694}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "b2aa1fadf4f84f9fa9f39a8fd405ee49"}
5	4	user_featurization	1745044395.3766496	\N	\N	{"event": "user_featurization", "timestamp": 1745044395.3766496, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
6	4	action	1745044395.3766496	\N	utter_greet	{"event": "action", "timestamp": 1745044395.3766496, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_greet", "policy": "MemoizationPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
7	4	bot	1745044395.3766496	\N	\N	{"event": "bot", "timestamp": 1745044395.3766496, "metadata": {"utter_action": "utter_greet", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Hi there! Welcome to our customer service. What can I assist you with?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
8	4	action	1745044395.3846498	\N	action_listen	{"event": "action", "timestamp": 1745044395.3846498, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.4953172206878662, "action_text": null, "hide_rule_turn": false}
9	4	user	1745044411.3009698	ask_order_status	\N	{"event": "user", "timestamp": 1745044411.3009698, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I need to know my orders", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9465926885604858}, "entities": [], "text": "I need to know my orders", "message_id": "c042b1944a9a41cb92ec2cf82d402625", "metadata": {}, "text_tokens": [[0, 1], [2, 6], [7, 9], [10, 14], [15, 17], [18, 24]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9465926885604858}, {"name": "ask_reset_password", "confidence": 0.012482993304729462}, {"name": "ask_shipping_time", "confidence": 0.009603849612176418}, {"name": "ask_order_cancel", "confidence": 0.008773473091423512}, {"name": "ask_return_policy", "confidence": 0.0059842560440301895}, {"name": "greet", "confidence": 0.003304230747744441}, {"name": "thank", "confidence": 0.0025949578266590834}, {"name": "ask_track_order", "confidence": 0.0019922794308513403}, {"name": "ask_product_availability", "confidence": 0.001979404129087925}, {"name": "goodbye", "confidence": 0.0018207305110991001}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "c042b1944a9a41cb92ec2cf82d402625"}
10	4	user_featurization	1745044411.3171291	\N	\N	{"event": "user_featurization", "timestamp": 1745044411.3171291, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
11	4	action	1745044411.3171291	\N	utter_ask_order_status_without_number	{"event": "action", "timestamp": 1745044411.3171291, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_ask_order_status_without_number", "policy": "MemoizationPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
12	4	bot	1745044411.3171291	\N	\N	{"event": "bot", "timestamp": 1745044411.3171291, "metadata": {"utter_action": "utter_ask_order_status_without_number", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'd be happy to check your order status. Could you please provide your order number?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
13	4	action	1745044411.3332915	\N	action_listen	{"event": "action", "timestamp": 1745044411.3332915, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "MemoizationPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
26	4	action	1745044678.740314	\N	utter_ask_order_status_without_number	{"event": "action", "timestamp": 1745044678.740314, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_ask_order_status_without_number", "policy": "TEDPolicy", "confidence": 0.992020308971405, "action_text": null, "hide_rule_turn": false}
27	4	bot	1745044678.740314	\N	\N	{"event": "bot", "timestamp": 1745044678.740314, "metadata": {"utter_action": "utter_ask_order_status_without_number", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'd be happy to check your order status. Could you please provide your order number?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
28	4	action	1745044678.7483375	\N	action_listen	{"event": "action", "timestamp": 1745044678.7483375, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.999862551689148, "action_text": null, "hide_rule_turn": false}
14	4	user	1745044421.471207	deny	\N	{"event": "user", "timestamp": 1745044421.471207, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I don't know", "parse_data": {"intent": {"name": "deny", "confidence": 0.9279861450195312}, "entities": [], "text": "I don't know", "message_id": "139f3af425dc4bbe9c25a80fd3847f8b", "metadata": {}, "text_tokens": [[0, 1], [2, 4], [4, 7], [8, 12]], "intent_ranking": [{"name": "deny", "confidence": 0.9279861450195312}, {"name": "ask_reset_password", "confidence": 0.02546478621661663}, {"name": "ask_product_availability", "confidence": 0.007983293384313583}, {"name": "goodbye", "confidence": 0.007615721318870783}, {"name": "ask_return_policy", "confidence": 0.006843310780823231}, {"name": "ask_shipping_time", "confidence": 0.003958459477871656}, {"name": "ask_order_status", "confidence": 0.0038660927675664425}, {"name": "ask_international_shipping", "confidence": 0.003422033740207553}, {"name": "greet", "confidence": 0.0032208759803324938}, {"name": "ask_create_account", "confidence": 0.002912878757342696}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "139f3af425dc4bbe9c25a80fd3847f8b"}
15	4	user_featurization	1745044421.486926	\N	\N	{"event": "user_featurization", "timestamp": 1745044421.486926, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
16	4	action	1745044421.486926	\N	utter_reset_password	{"event": "action", "timestamp": 1745044421.486926, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_reset_password", "policy": "TEDPolicy", "confidence": 0.6360794305801392, "action_text": null, "hide_rule_turn": false}
17	4	bot	1745044421.486926	\N	\N	{"event": "bot", "timestamp": 1745044421.486926, "metadata": {"utter_action": "utter_reset_password", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "To reset your password, click on 'Forgot Password' on the login page. We'll send you an email with instructions to create a new password.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
18	4	action	1745044421.5031042	\N	action_listen	{"event": "action", "timestamp": 1745044421.5031042, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9997748732566833, "action_text": null, "hide_rule_turn": false}
19	4	user	1745044436.6397252	ask_order_status	\N	{"event": "user", "timestamp": 1745044436.6397252, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I don't know my order number", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.8303832411766052}, "entities": [], "text": "I don't know my order number", "message_id": "ae61883877f547629a7693d4d7ff7628", "metadata": {}, "text_tokens": [[0, 1], [2, 4], [4, 7], [8, 12], [13, 15], [16, 21], [22, 28]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.8303832411766052}, {"name": "ask_reset_password", "confidence": 0.12556864321231842}, {"name": "ask_order_cancel", "confidence": 0.012411465868353844}, {"name": "deny", "confidence": 0.01067393459379673}, {"name": "ask_return_policy", "confidence": 0.004031325224786997}, {"name": "ask_shipping_time", "confidence": 0.00399335753172636}, {"name": "goodbye", "confidence": 0.0037202632520347834}, {"name": "ask_track_order", "confidence": 0.002730065491050482}, {"name": "ask_product_availability", "confidence": 0.0020831909496337175}, {"name": "ask_international_shipping", "confidence": 0.001524400315247476}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "ae61883877f547629a7693d4d7ff7628"}
20	4	user_featurization	1745044436.6558661	\N	\N	{"event": "user_featurization", "timestamp": 1745044436.6558661, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
21	4	action	1745044436.6558661	\N	utter_ask_order_status_without_number	{"event": "action", "timestamp": 1745044436.6558661, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_ask_order_status_without_number", "policy": "TEDPolicy", "confidence": 0.9919889569282532, "action_text": null, "hide_rule_turn": false}
22	4	bot	1745044436.6558661	\N	\N	{"event": "bot", "timestamp": 1745044436.6558661, "metadata": {"utter_action": "utter_ask_order_status_without_number", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'd be happy to check your order status. Could you please provide your order number?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
23	4	action	1745044436.6720755	\N	action_listen	{"event": "action", "timestamp": 1745044436.6720755, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998651742935181, "action_text": null, "hide_rule_turn": false}
24	4	user	1745044678.7156458	ask_order_status	\N	{"event": "user", "timestamp": 1745044678.7156458, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Hi, I need to know my order status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9992659687995911}, "entities": [], "text": "Hi, I need to know my order status", "message_id": "e175d42493784f77afb77ac8f6f21aef", "metadata": {}, "text_tokens": [[0, 2], [2, 3], [4, 5], [6, 10], [11, 13], [14, 18], [19, 21], [22, 27], [28, 34]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9992659687995911}, {"name": "greet", "confidence": 0.0003178117622155696}, {"name": "ask_reset_password", "confidence": 0.00010887865937547758}, {"name": "ask_shipping_time", "confidence": 9.44638013606891e-05}, {"name": "ask_return_policy", "confidence": 7.876857125665992e-05}, {"name": "ask_product_availability", "confidence": 6.474804104072973e-05}, {"name": "ask_order_cancel", "confidence": 1.4992970136518124e-05}, {"name": "ask_payment_methods", "confidence": 1.40849133458687e-05}, {"name": "thank", "confidence": 9.485744158155285e-06}, {"name": "deny", "confidence": 7.634136636625044e-06}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "e175d42493784f77afb77ac8f6f21aef"}
25	4	user_featurization	1745044678.740314	\N	\N	{"event": "user_featurization", "timestamp": 1745044678.740314, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
29	4	user	1745044690.366845	ask_order_status	\N	{"event": "user", "timestamp": 1745044690.366845, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "ORD-67690  this is my order number", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9963430762290955}, "entities": [{"entity": "order_number", "start": 0, "end": 9, "confidence_entity": 0.7604176998138428, "value": "ORD-67690", "extractor": "DIETClassifier"}], "text": "ORD-67690  this is my order number", "message_id": "81ee2af3f9c3499bb1e6e0f2aa733ed3", "metadata": {}, "text_tokens": [[0, 9], [11, 15], [16, 18], [19, 21], [22, 27], [28, 34]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9963430762290955}, {"name": "ask_reset_password", "confidence": 0.0012749979505315423}, {"name": "ask_order_cancel", "confidence": 0.0010040090419352055}, {"name": "greet", "confidence": 0.00041062969830818474}, {"name": "ask_return_policy", "confidence": 0.00018721971719060093}, {"name": "ask_track_order", "confidence": 0.0001678655535215512}, {"name": "ask_product_availability", "confidence": 0.00011976794485235587}, {"name": "ask_shipping_time", "confidence": 0.0001081734590115957}, {"name": "deny", "confidence": 9.22733815968968e-05}, {"name": "thank", "confidence": 8.068692841334268e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "81ee2af3f9c3499bb1e6e0f2aa733ed3"}
30	4	slot	1745044690.366845	\N	order_number	{"event": "slot", "timestamp": 1745044690.366845, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
31	4	user_featurization	1745044694.5154748	\N	\N	{"event": "user_featurization", "timestamp": 1745044694.5154748, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
32	4	action	1745044694.5154748	\N	action_check_order_status	{"event": "action", "timestamp": 1745044694.5154748, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.9983188509941101, "action_text": null, "hide_rule_turn": false}
33	4	bot	1745044694.5154748	\N	\N	{"event": "bot", "timestamp": 1745044694.5154748, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
34	4	action	1745044694.5234838	\N	action_listen	{"event": "action", "timestamp": 1745044694.5234838, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998290538787842, "action_text": null, "hide_rule_turn": false}
35	4	user	1745046102.8011446	greet	\N	{"event": "user", "timestamp": 1745046102.8011446, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "hi", "parse_data": {"intent": {"name": "greet", "confidence": 0.9954788088798523}, "entities": [], "text": "hi", "message_id": "8eab81699f9149f0af3782d71a68072c", "metadata": {}, "text_tokens": [[0, 2]], "intent_ranking": [{"name": "greet", "confidence": 0.9954788088798523}, {"name": "ask_order_status", "confidence": 0.0014418027130886912}, {"name": "deny", "confidence": 0.00049217464402318}, {"name": "out_of_scope", "confidence": 0.00041197490645572543}, {"name": "ask_track_order", "confidence": 0.000279021478490904}, {"name": "ask_shipping_time", "confidence": 0.00025088488473556936}, {"name": "ask_payment_methods", "confidence": 0.00023734100977890193}, {"name": "affirm", "confidence": 0.00023431364388670772}, {"name": "ask_return_policy", "confidence": 0.00023091623734217137}, {"name": "ask_international_shipping", "confidence": 0.00022463045024778694}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "8eab81699f9149f0af3782d71a68072c"}
36	4	user_featurization	1745046103.8626392	\N	\N	{"event": "user_featurization", "timestamp": 1745046103.8626392, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
37	4	action	1745046103.8626392	\N	utter_greet	{"event": "action", "timestamp": 1745046103.8626392, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_greet", "policy": "TEDPolicy", "confidence": 0.9967790246009827, "action_text": null, "hide_rule_turn": false}
38	4	bot	1745046103.8626392	\N	\N	{"event": "bot", "timestamp": 1745046103.8626392, "metadata": {"utter_action": "utter_greet", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Hi there! Welcome to our customer service. What can I assist you with?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
39	4	action	1745046103.8706644	\N	action_listen	{"event": "action", "timestamp": 1745046103.8706644, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.4978201389312744, "action_text": null, "hide_rule_turn": false}
40	4	user	1745046159.4096813	ask_order_status	\N	{"event": "user", "timestamp": 1745046159.4096813, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I want to know my order status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9997342228889465}, "entities": [], "text": "I want to know my order status", "message_id": "af48f5571c9f45119936cd9e5d7ea4bc", "metadata": {}, "text_tokens": [[0, 1], [2, 6], [7, 9], [10, 14], [15, 17], [18, 23], [24, 30]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9997342228889465}, {"name": "ask_reset_password", "confidence": 0.00013005819346290082}, {"name": "ask_shipping_time", "confidence": 3.857355841319077e-05}, {"name": "greet", "confidence": 2.3531603801529855e-05}, {"name": "ask_return_policy", "confidence": 1.8542476027505472e-05}, {"name": "affirm", "confidence": 1.475522276450647e-05}, {"name": "ask_product_availability", "confidence": 1.4290372746472713e-05}, {"name": "ask_payment_methods", "confidence": 7.282176738954149e-06}, {"name": "ask_order_cancel", "confidence": 5.892328317713691e-06}, {"name": "thank", "confidence": 3.834938979707658e-06}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "af48f5571c9f45119936cd9e5d7ea4bc"}
41	4	user_featurization	1745046159.433868	\N	\N	{"event": "user_featurization", "timestamp": 1745046159.433868, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
42	4	action	1745046159.433868	\N	utter_ask_order_status_without_number	{"event": "action", "timestamp": 1745046159.433868, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_ask_order_status_without_number", "policy": "TEDPolicy", "confidence": 0.9920492768287659, "action_text": null, "hide_rule_turn": false}
43	4	bot	1745046159.433868	\N	\N	{"event": "bot", "timestamp": 1745046159.433868, "metadata": {"utter_action": "utter_ask_order_status_without_number", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'd be happy to check your order status. Could you please provide your order number?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
44	4	action	1745046159.4500647	\N	action_listen	{"event": "action", "timestamp": 1745046159.4500647, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.999873161315918, "action_text": null, "hide_rule_turn": false}
45	4	user	1745046181.4158494	ask_order_status	\N	{"event": "user", "timestamp": 1745046181.4158494, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9960783123970032}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9766077995300293, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666", "message_id": "8bd6f75aeace4978a5937bf057c9b168", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9960783123970032}, {"name": "ask_reset_password", "confidence": 0.0015128133818507195}, {"name": "ask_order_cancel", "confidence": 0.0011769538978114724}, {"name": "ask_track_order", "confidence": 0.0002750307321548462}, {"name": "greet", "confidence": 0.00026616198010742664}, {"name": "ask_return_policy", "confidence": 0.00016452134877908975}, {"name": "ask_product_availability", "confidence": 0.00012221034558024257}, {"name": "ask_shipping_time", "confidence": 8.554950909456238e-05}, {"name": "thank", "confidence": 7.89694458944723e-05}, {"name": "affirm", "confidence": 5.3843959904043004e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "8bd6f75aeace4978a5937bf057c9b168"}
46	4	slot	1745046181.4158494	\N	order_number	{"event": "slot", "timestamp": 1745046181.4158494, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
47	4	user_featurization	1745046185.5946584	\N	\N	{"event": "user_featurization", "timestamp": 1745046185.5946584, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
48	4	action	1745046185.5946584	\N	action_check_order_status	{"event": "action", "timestamp": 1745046185.5946584, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.9991728663444519, "action_text": null, "hide_rule_turn": false}
49	4	bot	1745046185.5946584	\N	\N	{"event": "bot", "timestamp": 1745046185.5946584, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
50	4	action	1745046185.6109073	\N	action_listen	{"event": "action", "timestamp": 1745046185.6109073, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9997950196266174, "action_text": null, "hide_rule_turn": false}
51	4	user	1745046420.0488465	greet	\N	{"event": "user", "timestamp": 1745046420.0488465, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "hi", "parse_data": {"intent": {"name": "greet", "confidence": 0.9954788088798523}, "entities": [], "text": "hi", "message_id": "c1f5efcabd8140f1b3e2a0f539f65ee3", "metadata": {}, "text_tokens": [[0, 2]], "intent_ranking": [{"name": "greet", "confidence": 0.9954788088798523}, {"name": "ask_order_status", "confidence": 0.0014418027130886912}, {"name": "deny", "confidence": 0.00049217464402318}, {"name": "out_of_scope", "confidence": 0.00041197490645572543}, {"name": "ask_track_order", "confidence": 0.000279021478490904}, {"name": "ask_shipping_time", "confidence": 0.00025088488473556936}, {"name": "ask_payment_methods", "confidence": 0.00023734100977890193}, {"name": "affirm", "confidence": 0.00023431364388670772}, {"name": "ask_return_policy", "confidence": 0.00023091623734217137}, {"name": "ask_international_shipping", "confidence": 0.00022463045024778694}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "c1f5efcabd8140f1b3e2a0f539f65ee3"}
52	4	user_featurization	1745046420.0648775	\N	\N	{"event": "user_featurization", "timestamp": 1745046420.0648775, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
53	4	action	1745046420.0648775	\N	utter_greet	{"event": "action", "timestamp": 1745046420.0648775, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_greet", "policy": "TEDPolicy", "confidence": 0.9965974688529968, "action_text": null, "hide_rule_turn": false}
54	4	bot	1745046420.0648775	\N	\N	{"event": "bot", "timestamp": 1745046420.0648775, "metadata": {"utter_action": "utter_greet", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Hi there! Welcome to our customer service. What can I assist you with?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
55	4	action	1745046420.0816457	\N	action_listen	{"event": "action", "timestamp": 1745046420.0816457, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.48329174518585205, "action_text": null, "hide_rule_turn": false}
65	4	action	1745046436.8705351	\N	utter_out_of_scope	{"event": "action", "timestamp": 1745046436.8705351, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_out_of_scope", "policy": "TEDPolicy", "confidence": 0.9807198643684387, "action_text": null, "hide_rule_turn": false}
56	4	user	1745046429.4148612	greet	\N	{"event": "user", "timestamp": 1745046429.4148612, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "hello", "parse_data": {"intent": {"name": "greet", "confidence": 0.9987504482269287}, "entities": [], "text": "hello", "message_id": "dcf2c7bca1f24851aa884af05ff196de", "metadata": {}, "text_tokens": [[0, 5]], "intent_ranking": [{"name": "greet", "confidence": 0.9987504482269287}, {"name": "ask_order_status", "confidence": 0.0003127574163954705}, {"name": "affirm", "confidence": 0.00014123185246717185}, {"name": "out_of_scope", "confidence": 0.0001299268624279648}, {"name": "deny", "confidence": 0.00012701349623966962}, {"name": "ask_payment_methods", "confidence": 0.0001108569122152403}, {"name": "ask_international_shipping", "confidence": 6.355294317472726e-05}, {"name": "ask_shipping_time", "confidence": 6.247279088711366e-05}, {"name": "ask_return_policy", "confidence": 6.091774412197992e-05}, {"name": "goodbye", "confidence": 5.92024480283726e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "dcf2c7bca1f24851aa884af05ff196de"}
57	4	user_featurization	1745046429.4417467	\N	\N	{"event": "user_featurization", "timestamp": 1745046429.4417467, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
58	4	action	1745046429.4417467	\N	action_unlikely_intent	{"event": "action", "timestamp": 1745046429.4417467, "metadata": {"query_intent": {"name": "greet", "score": -1.7322297096252441, "threshold": -0.3770428001880646, "severity": 1.355186939239502}, "ranking": [{"name": "thank", "score": 0.3513137698173523, "threshold": -0.48458972573280334, "severity": -0.835903525352478}, {"name": "ask_order_status", "score": 0.24815469980239868, "threshold": -0.13049501180648804, "severity": -0.3786497116088867}, {"name": "ask_track_order", "score": 0.003381580114364624, "threshold": -0.22128751873970032, "severity": -0.22466909885406494}, {"name": "goodbye", "score": -0.011499449610710144, "threshold": -0.7157459259033203, "severity": -0.704246461391449}, {"name": "ask_create_account", "score": -1.2282373905181885, "threshold": -0.5867963433265686, "severity": 0.6414410471916199}, {"name": "ask_shipping_time", "score": -1.3052512407302856, "threshold": -0.39992058277130127, "severity": 0.9053306579589844}, {"name": "ask_reset_password", "score": -1.3117730617523193, "threshold": -0.514826238155365, "severity": 0.7969468235969543}, {"name": "ask_international_shipping", "score": -1.3173617124557495, "threshold": -0.22915658354759216, "severity": 1.088205099105835}, {"name": "back", "score": -1.3268723487854004, "threshold": null, "severity": null}, {"name": "ask_order_cancel", "score": -1.3430790901184082, "threshold": -0.4927312135696411, "severity": 0.8503478765487671}], "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_unlikely_intent", "policy": "UnexpecTEDIntentPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
59	4	action	1745046429.4478068	\N	utter_greet	{"event": "action", "timestamp": 1745046429.4478068, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_greet", "policy": "TEDPolicy", "confidence": 0.9960337281227112, "action_text": null, "hide_rule_turn": false}
60	4	bot	1745046429.4478068	\N	\N	{"event": "bot", "timestamp": 1745046429.4478068, "metadata": {"utter_action": "utter_greet", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Good day! I'm here to help with any questions about your orders or our products.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
61	4	action	1745046429.4640057	\N	action_listen	{"event": "action", "timestamp": 1745046429.4640057, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.4796212315559387, "action_text": null, "hide_rule_turn": false}
62	4	user	1745046436.829894	out_of_scope	\N	{"event": "user", "timestamp": 1745046436.829894, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "how are you", "parse_data": {"intent": {"name": "out_of_scope", "confidence": 0.7877587080001831}, "entities": [], "text": "how are you", "message_id": "b44c4efc894949d5a12d073702b490da", "metadata": {}, "text_tokens": [[0, 3], [4, 7], [8, 11]], "intent_ranking": [{"name": "out_of_scope", "confidence": 0.7877587080001831}, {"name": "thank", "confidence": 0.03956891596317291}, {"name": "affirm", "confidence": 0.034775521606206894}, {"name": "greet", "confidence": 0.026859648525714874}, {"name": "ask_payment_methods", "confidence": 0.019182434305548668}, {"name": "ask_product_availability", "confidence": 0.016829963773489}, {"name": "ask_order_status", "confidence": 0.015005173161625862}, {"name": "ask_track_order", "confidence": 0.013482426293194294}, {"name": "ask_reset_password", "confidence": 0.009875007905066013}, {"name": "ask_return_policy", "confidence": 0.008301042951643467}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "b44c4efc894949d5a12d073702b490da"}
63	4	user_featurization	1745046436.8545315	\N	\N	{"event": "user_featurization", "timestamp": 1745046436.8545315, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
64	4	action	1745046436.8545315	\N	action_unlikely_intent	{"event": "action", "timestamp": 1745046436.8545315, "metadata": {"query_intent": {"name": "out_of_scope", "score": -1.5669317245483398, "threshold": -0.16629403829574585, "severity": 1.4006376266479492}, "ranking": [{"name": "thank", "score": 0.3174761235713959, "threshold": -0.48458972573280334, "severity": -0.8020658493041992}, {"name": "ask_order_status", "score": 0.148035928606987, "threshold": -0.13049501180648804, "severity": -0.27853095531463623}, {"name": "goodbye", "score": -0.09490002691745758, "threshold": -0.7157459259033203, "severity": -0.6208459138870239}, {"name": "ask_track_order", "score": -0.09931735694408417, "threshold": -0.22128751873970032, "severity": -0.12197016179561615}, {"name": "ask_create_account", "score": -1.2622449398040771, "threshold": -0.5867963433265686, "severity": 0.6754485964775085}, {"name": "back", "score": -1.3438189029693604, "threshold": null, "severity": null}, {"name": "ask_international_shipping", "score": -1.3657076358795166, "threshold": -0.22915658354759216, "severity": 1.136551022529602}, {"name": "ask_reset_password", "score": -1.3751024007797241, "threshold": -0.514826238155365, "severity": 0.8602761626243591}, {"name": "ask_order_cancel", "score": -1.407418131828308, "threshold": -0.4927312135696411, "severity": 0.914686918258667}, {"name": "ask_shipping_time", "score": -1.4205718040466309, "threshold": -0.39992058277130127, "severity": 1.0206512212753296}], "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_unlikely_intent", "policy": "UnexpecTEDIntentPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
66	4	bot	1745046436.8705351	\N	\N	{"event": "bot", "timestamp": 1745046436.8705351, "metadata": {"utter_action": "utter_out_of_scope", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "That's beyond my current capabilities. I can help with questions about orders, shipping, returns, and account management. Could you ask something in those areas?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
67	4	action	1745046436.8787417	\N	action_listen	{"event": "action", "timestamp": 1745046436.8787417, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9997658133506775, "action_text": null, "hide_rule_turn": false}
68	4	user	1745046444.7176783	ask_order_status	\N	{"event": "user", "timestamp": 1745046444.7176783, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9960783123970032}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9766077995300293, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666", "message_id": "486ccdbb7f2e4a7e8766df665e113dbf", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9960783123970032}, {"name": "ask_reset_password", "confidence": 0.0015128133818507195}, {"name": "ask_order_cancel", "confidence": 0.0011769538978114724}, {"name": "ask_track_order", "confidence": 0.0002750307321548462}, {"name": "greet", "confidence": 0.00026616198010742664}, {"name": "ask_return_policy", "confidence": 0.00016452134877908975}, {"name": "ask_product_availability", "confidence": 0.00012221034558024257}, {"name": "ask_shipping_time", "confidence": 8.554950909456238e-05}, {"name": "thank", "confidence": 7.89694458944723e-05}, {"name": "affirm", "confidence": 5.3843959904043004e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "486ccdbb7f2e4a7e8766df665e113dbf"}
69	4	slot	1745046444.7176783	\N	order_number	{"event": "slot", "timestamp": 1745046444.7176783, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
70	4	user_featurization	1745046448.8994033	\N	\N	{"event": "user_featurization", "timestamp": 1745046448.8994033, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
71	4	action	1745046448.8994033	\N	action_check_order_status	{"event": "action", "timestamp": 1745046448.8994033, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.9993724226951599, "action_text": null, "hide_rule_turn": false}
72	4	bot	1745046448.8994033	\N	\N	{"event": "bot", "timestamp": 1745046448.8994033, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
73	4	action	1745046448.9154475	\N	action_listen	{"event": "action", "timestamp": 1745046448.9154475, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9997971653938293, "action_text": null, "hide_rule_turn": false}
74	4	user	1745046624.3304381	ask_order_status	\N	{"event": "user", "timestamp": 1745046624.3304381, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9960783123970032}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9766077995300293, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666", "message_id": "55cf84d86b0f4598a6c09b79c8689f0a", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9960783123970032}, {"name": "ask_reset_password", "confidence": 0.0015128133818507195}, {"name": "ask_order_cancel", "confidence": 0.0011769538978114724}, {"name": "ask_track_order", "confidence": 0.0002750307321548462}, {"name": "greet", "confidence": 0.00026616198010742664}, {"name": "ask_return_policy", "confidence": 0.00016452134877908975}, {"name": "ask_product_availability", "confidence": 0.00012221034558024257}, {"name": "ask_shipping_time", "confidence": 8.554950909456238e-05}, {"name": "thank", "confidence": 7.89694458944723e-05}, {"name": "affirm", "confidence": 5.3843959904043004e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "55cf84d86b0f4598a6c09b79c8689f0a"}
75	4	slot	1745046624.3304381	\N	order_number	{"event": "slot", "timestamp": 1745046624.3304381, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
76	4	user_featurization	1745046628.5086832	\N	\N	{"event": "user_featurization", "timestamp": 1745046628.5086832, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
77	4	action	1745046628.5086832	\N	action_check_order_status	{"event": "action", "timestamp": 1745046628.5086832, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.935601532459259, "action_text": null, "hide_rule_turn": false}
78	4	bot	1745046628.5086832	\N	\N	{"event": "bot", "timestamp": 1745046628.5086832, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
79	4	action	1745046628.5204928	\N	action_listen	{"event": "action", "timestamp": 1745046628.5204928, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998095631599426, "action_text": null, "hide_rule_turn": false}
260	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
80	4	user	1745046953.5706322	ask_order_status	\N	{"event": "user", "timestamp": 1745046953.5706322, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "709641c409d7459d856ebf8a9c4e4dcc", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "709641c409d7459d856ebf8a9c4e4dcc"}
81	4	slot	1745046953.5706322	\N	order_number	{"event": "slot", "timestamp": 1745046953.5706322, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
82	4	user_featurization	1745046954.6234505	\N	\N	{"event": "user_featurization", "timestamp": 1745046954.6234505, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
83	4	action	1745046954.6234505	\N	action_unlikely_intent	{"event": "action", "timestamp": 1745046954.6234505, "metadata": {"query_intent": {"name": "ask_order_status", "score": -0.15000532567501068, "threshold": -0.13049501180648804, "severity": 0.019510313868522644}, "ranking": [{"name": "ask_track_order", "score": 0.23152628540992737, "threshold": -0.22128751873970032, "severity": -0.4528138041496277}, {"name": "ask_order_status", "score": -0.15000532567501068, "threshold": -0.13049501180648804, "severity": 0.019510313868522644}, {"name": "greet", "score": -0.23592332005500793, "threshold": -0.3770428001880646, "severity": -0.14111948013305664}, {"name": "thank", "score": -0.3245388865470886, "threshold": -0.48458972573280334, "severity": -0.16005083918571472}, {"name": "ask_order_cancel", "score": -0.4071606993675232, "threshold": -0.4927312135696411, "severity": -0.08557051420211792}, {"name": "ask_reset_password", "score": -0.4639264941215515, "threshold": -0.514826238155365, "severity": -0.05089974403381348}, {"name": "ask_payment_methods", "score": -0.4733063578605652, "threshold": -0.36960339546203613, "severity": 0.10370296239852905}, {"name": "ask_create_account", "score": -0.5277684330940247, "threshold": -0.5867963433265686, "severity": -0.059027910232543945}, {"name": "ask_return_policy", "score": -0.5653799772262573, "threshold": -0.31600886583328247, "severity": 0.24937111139297485}, {"name": "ask_international_shipping", "score": -0.5984333753585815, "threshold": -0.22915658354759216, "severity": 0.3692767918109894}], "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_unlikely_intent", "policy": "UnexpecTEDIntentPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
84	4	action	1745046958.7885215	\N	action_check_order_status	{"event": "action", "timestamp": 1745046958.7885215, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
85	4	bot	1745046958.7885215	\N	\N	{"event": "bot", "timestamp": 1745046958.7885215, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
86	4	action	1745046958.8060608	\N	action_listen	{"event": "action", "timestamp": 1745046958.8060608, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
87	4	user	1745047078.6289935	ask_order_status	\N	{"event": "user", "timestamp": 1745047078.6289935, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "f182456bac8743bc81694878309191b0", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "f182456bac8743bc81694878309191b0"}
88	4	slot	1745047078.6289935	\N	order_number	{"event": "slot", "timestamp": 1745047078.6289935, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
89	4	user_featurization	1745047082.777066	\N	\N	{"event": "user_featurization", "timestamp": 1745047082.777066, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
90	4	action	1745047082.777066	\N	action_check_order_status	{"event": "action", "timestamp": 1745047082.777066, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
91	4	bot	1745047082.777066	\N	\N	{"event": "bot", "timestamp": 1745047082.777066, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
92	4	action	1745047082.7939923	\N	action_listen	{"event": "action", "timestamp": 1745047082.7939923, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
93	4	user	1745047145.7084038	ask_order_status	\N	{"event": "user", "timestamp": 1745047145.7084038, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "e18c90d88809417e83f68f66af5f4019", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "e18c90d88809417e83f68f66af5f4019"}
94	4	slot	1745047145.7084038	\N	order_number	{"event": "slot", "timestamp": 1745047145.7084038, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
95	4	user_featurization	1745047149.8286467	\N	\N	{"event": "user_featurization", "timestamp": 1745047149.8286467, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
96	4	action	1745047149.8286467	\N	action_check_order_status	{"event": "action", "timestamp": 1745047149.8286467, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
97	4	bot	1745047149.8286467	\N	\N	{"event": "bot", "timestamp": 1745047149.8286467, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
98	4	action	1745047149.857839	\N	action_listen	{"event": "action", "timestamp": 1745047149.857839, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
99	4	user	1745047191.3910089	ask_order_status	\N	{"event": "user", "timestamp": 1745047191.3910089, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "486103b8c5bc4e1c8c3e9689d526b4ce", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "486103b8c5bc4e1c8c3e9689d526b4ce"}
100	4	slot	1745047191.3910089	\N	order_number	{"event": "slot", "timestamp": 1745047191.3910089, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
101	4	user_featurization	1745047195.5757442	\N	\N	{"event": "user_featurization", "timestamp": 1745047195.5757442, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
102	4	action	1745047195.5757442	\N	action_check_order_status	{"event": "action", "timestamp": 1745047195.5757442, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
103	4	bot	1745047195.5757442	\N	\N	{"event": "bot", "timestamp": 1745047195.5757442, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
104	4	action	1745047195.5938852	\N	action_listen	{"event": "action", "timestamp": 1745047195.5938852, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
105	4	user	1745047550.3772357	ask_order_status	\N	{"event": "user", "timestamp": 1745047550.3772357, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "92f1ae0ad5eb4bd6a5ff86b254e7310a", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "92f1ae0ad5eb4bd6a5ff86b254e7310a"}
106	4	slot	1745047550.3856034	\N	order_number	{"event": "slot", "timestamp": 1745047550.3856034, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
107	4	user_featurization	1745047555.639099	\N	\N	{"event": "user_featurization", "timestamp": 1745047555.639099, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
108	4	action	1745047555.639099	\N	action_check_order_status	{"event": "action", "timestamp": 1745047555.639099, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
109	4	bot	1745047555.639099	\N	\N	{"event": "bot", "timestamp": 1745047555.639099, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
110	4	action	1745047555.6553373	\N	action_listen	{"event": "action", "timestamp": 1745047555.6553373, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
111	4	user	1745047738.5878143	ask_order_status	\N	{"event": "user", "timestamp": 1745047738.5878143, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "76195d97ba2c4d6888c89e785e707412", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "76195d97ba2c4d6888c89e785e707412"}
112	4	slot	1745047738.5878143	\N	order_number	{"event": "slot", "timestamp": 1745047738.5878143, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
113	4	user_featurization	1745047742.7323177	\N	\N	{"event": "user_featurization", "timestamp": 1745047742.7323177, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
114	4	action	1745047742.7323177	\N	action_check_order_status	{"event": "action", "timestamp": 1745047742.7323177, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
115	4	bot	1745047742.7323177	\N	\N	{"event": "bot", "timestamp": 1745047742.7323177, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
116	4	action	1745047742.765534	\N	action_listen	{"event": "action", "timestamp": 1745047742.765534, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
189	4	action	1745051267.7371304	\N	action_list_order_items	{"event": "action", "timestamp": 1745051267.7371304, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_list_order_items", "policy": "TEDPolicy", "confidence": 0.86034095287323, "action_text": null, "hide_rule_turn": false}
190	4	bot	1745051267.7371304	\N	\N	{"event": "bot", "timestamp": 1745051267.7371304, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I couldn't find an order with number ORD-67690. Please check the number and try again.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
117	4	user	1745047871.7923818	ask_order_status	\N	{"event": "user", "timestamp": 1745047871.7923818, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "7e133b65cb1540ae9d90cdf6160420c3", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "7e133b65cb1540ae9d90cdf6160420c3"}
118	4	slot	1745047871.7923818	\N	order_number	{"event": "slot", "timestamp": 1745047871.7923818, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
119	4	user_featurization	1745047875.963259	\N	\N	{"event": "user_featurization", "timestamp": 1745047875.963259, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
120	4	action	1745047875.963259	\N	action_check_order_status	{"event": "action", "timestamp": 1745047875.963259, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
121	4	bot	1745047875.963259	\N	\N	{"event": "bot", "timestamp": 1745047875.963259, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
122	4	action	1745047875.9934947	\N	action_listen	{"event": "action", "timestamp": 1745047875.9934947, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
123	4	user	1745047995.950918	ask_order_status	\N	{"event": "user", "timestamp": 1745047995.950918, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "57e10fc4217646a0ab089e04ef0cd03b", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "57e10fc4217646a0ab089e04ef0cd03b"}
124	4	slot	1745047995.950918	\N	order_number	{"event": "slot", "timestamp": 1745047995.950918, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
125	4	user_featurization	1745048000.1317174	\N	\N	{"event": "user_featurization", "timestamp": 1745048000.1317174, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
126	4	action	1745048000.1317174	\N	action_check_order_status	{"event": "action", "timestamp": 1745048000.1317174, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
127	4	bot	1745048000.1317174	\N	\N	{"event": "bot", "timestamp": 1745048000.1317174, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
128	4	action	1745048000.147943	\N	action_listen	{"event": "action", "timestamp": 1745048000.147943, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
191	4	slot	1745051267.7371304	\N	order_number	{"event": "slot", "timestamp": 1745051267.7371304, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": null}
192	4	action	1745051267.761542	\N	action_listen	{"event": "action", "timestamp": 1745051267.761542, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9997819066047668, "action_text": null, "hide_rule_turn": false}
261	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
129	4	user	1745048144.9131384	ask_order_status	\N	{"event": "user", "timestamp": 1745048144.9131384, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "06470a5e42f24ffa9744dc799cbf2809", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "06470a5e42f24ffa9744dc799cbf2809"}
130	4	slot	1745048144.9131384	\N	order_number	{"event": "slot", "timestamp": 1745048144.9131384, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
131	4	user_featurization	1745048149.1001909	\N	\N	{"event": "user_featurization", "timestamp": 1745048149.1001909, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
132	4	action	1745048149.1001909	\N	action_check_order_status	{"event": "action", "timestamp": 1745048149.1001909, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
133	4	bot	1745048149.1001909	\N	\N	{"event": "bot", "timestamp": 1745048149.1001909, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
134	4	action	1745048149.1168447	\N	action_listen	{"event": "action", "timestamp": 1745048149.1168447, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
135	4	user	1745048322.2896159	ask_order_status	\N	{"event": "user", "timestamp": 1745048322.2896159, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "66d6802e39494e83905fa4330d553ebd", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "66d6802e39494e83905fa4330d553ebd"}
136	4	slot	1745048322.2896159	\N	order_number	{"event": "slot", "timestamp": 1745048322.2896159, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
137	4	user_featurization	1745048326.4628062	\N	\N	{"event": "user_featurization", "timestamp": 1745048326.4628062, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
138	4	action	1745048326.4628062	\N	action_check_order_status	{"event": "action", "timestamp": 1745048326.4628062, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
139	4	bot	1745048326.4628062	\N	\N	{"event": "bot", "timestamp": 1745048326.4628062, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
140	4	action	1745048326.4788141	\N	action_listen	{"event": "action", "timestamp": 1745048326.4788141, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
244	4	slot	1745053124.984298	\N	confirm_cancel	{"event": "slot", "timestamp": 1745053124.984298, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "confirmed"}
245	4	followup	1745053124.984298	\N	action_cancel_order	{"event": "followup", "timestamp": 1745053124.984298, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_cancel_order"}
246	4	action	1745053129.138626	\N	action_cancel_order	{"event": "action", "timestamp": 1745053129.138626, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_cancel_order", "policy": "followup_action", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
141	4	user	1745050092.1742384	ask_order_status	\N	{"event": "user", "timestamp": 1745050092.1742384, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "73d4f04f4a8d4eccb7b79613eccf8e1f", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "73d4f04f4a8d4eccb7b79613eccf8e1f"}
142	4	slot	1745050092.182386	\N	order_number	{"event": "slot", "timestamp": 1745050092.182386, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
143	4	user_featurization	1745050097.3829463	\N	\N	{"event": "user_featurization", "timestamp": 1745050097.3829463, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
144	4	action	1745050097.3829463	\N	action_check_order_status	{"event": "action", "timestamp": 1745050097.3829463, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
145	4	bot	1745050097.3829463	\N	\N	{"event": "bot", "timestamp": 1745050097.3829463, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
146	4	action	1745050097.3991497	\N	action_listen	{"event": "action", "timestamp": 1745050097.3991497, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
147	4	user	1745050223.918396	ask_order_status	\N	{"event": "user", "timestamp": 1745050223.918396, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "f4593f41c6634320bb521f4d549530ef", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "f4593f41c6634320bb521f4d549530ef"}
148	4	slot	1745050223.918396	\N	order_number	{"event": "slot", "timestamp": 1745050223.918396, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
149	4	user_featurization	1745050228.0801342	\N	\N	{"event": "user_featurization", "timestamp": 1745050228.0801342, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
150	4	action	1745050228.0801342	\N	action_check_order_status	{"event": "action", "timestamp": 1745050228.0801342, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
151	4	bot	1745050228.0801342	\N	\N	{"event": "bot", "timestamp": 1745050228.0801342, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
152	4	action	1745050228.0962977	\N	action_listen	{"event": "action", "timestamp": 1745050228.0962977, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
247	4	bot	1745053129.138626	\N	\N	{"event": "bot", "timestamp": 1745053129.138626, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I've successfully cancelled your order #ORD-67690.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
248	4	bot	1745053129.138626	\N	\N	{"event": "bot", "timestamp": 1745053129.138626, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "text": "If you made this cancellation by mistake, please contact our customer support immediately.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
153	4	user	1745050544.9728222	ask_order_status	\N	{"event": "user", "timestamp": 1745050544.9728222, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "9ffcbdbd453d41f88cd422c9015771a0", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "9ffcbdbd453d41f88cd422c9015771a0"}
154	4	slot	1745050544.9728222	\N	order_number	{"event": "slot", "timestamp": 1745050544.9728222, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
155	4	user_featurization	1745050550.143905	\N	\N	{"event": "user_featurization", "timestamp": 1745050550.143905, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
156	4	action	1745050550.143905	\N	action_check_order_status	{"event": "action", "timestamp": 1745050550.143905, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
157	4	bot	1745050550.143905	\N	\N	{"event": "bot", "timestamp": 1745050550.143905, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'm having trouble connecting to our order system. Please try again later or contact customer support.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
158	4	action	1745050550.1600404	\N	action_listen	{"event": "action", "timestamp": 1745050550.1600404, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
159	4	user	1745050941.2916448	ask_order_status	\N	{"event": "user", "timestamp": 1745050941.2916448, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-51666 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-51666", "extractor": "DIETClassifier"}], "text": "my order number is ORD-51666 need to know the status", "message_id": "f75b09cb7dd0407692e8728ccf587928", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "f75b09cb7dd0407692e8728ccf587928"}
160	4	slot	1745050941.2916448	\N	order_number	{"event": "slot", "timestamp": 1745050941.2916448, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
161	4	user_featurization	1745050946.4948156	\N	\N	{"event": "user_featurization", "timestamp": 1745050946.4948156, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
162	4	action	1745050946.4948156	\N	action_check_order_status	{"event": "action", "timestamp": 1745050946.4948156, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
163	4	bot	1745050946.4948156	\N	\N	{"event": "bot", "timestamp": 1745050946.4948156, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Your order ORD-51666 has been cancelled. If you didn't cancel it, please contact our support team.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
164	4	slot	1745050946.4948156	\N	order_number	{"event": "slot", "timestamp": 1745050946.4948156, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
165	4	action	1745050946.511001	\N	action_listen	{"event": "action", "timestamp": 1745050946.511001, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
249	4	slot	1745053129.138626	\N	order_number	{"event": "slot", "timestamp": 1745053129.138626, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
250	4	slot	1745053129.138626	\N	confirm_cancel	{"event": "slot", "timestamp": 1745053129.138626, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": null}
166	4	user	1745050983.6659496	ask_order_status	\N	{"event": "user", "timestamp": 1745050983.6659496, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-67690 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-67690", "extractor": "DIETClassifier"}], "text": "my order number is ORD-67690 need to know the status", "message_id": "189975f76cc64a5683b2c6ae8762c0e0", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "189975f76cc64a5683b2c6ae8762c0e0"}
167	4	slot	1745050983.6659496	\N	order_number	{"event": "slot", "timestamp": 1745050983.6659496, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
168	4	user_featurization	1745050987.8526163	\N	\N	{"event": "user_featurization", "timestamp": 1745050987.8526163, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
169	4	action	1745050987.8526163	\N	action_check_order_status	{"event": "action", "timestamp": 1745050987.8526163, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.6569616794586182, "action_text": null, "hide_rule_turn": false}
170	4	bot	1745050987.8526163	\N	\N	{"event": "bot", "timestamp": 1745050987.8526163, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Your order ORD-67690 is pending. We're processing it now. Estimated delivery: March 08, 2025.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
171	4	slot	1745050987.8526163	\N	order_number	{"event": "slot", "timestamp": 1745050987.8526163, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
172	4	action	1745050987.8694022	\N	action_listen	{"event": "action", "timestamp": 1745050987.8694022, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998083710670471, "action_text": null, "hide_rule_turn": false}
173	4	user	1745051011.10728	nlu_fallback	\N	{"event": "user", "timestamp": 1745051011.10728, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "are you able to list down the items in the order", "parse_data": {"intent": {"name": "nlu_fallback", "confidence": 0.7}, "entities": [], "text": "are you able to list down the items in the order", "message_id": "2db17a3731414e4ebd3881561cb52c4f", "metadata": {}, "text_tokens": [[0, 3], [4, 7], [8, 12], [13, 15], [16, 20], [21, 25], [26, 29], [30, 35], [36, 38], [39, 42], [43, 48]], "intent_ranking": [{"name": "nlu_fallback", "confidence": 0.7}, {"name": "ask_product_availability", "confidence": 0.5298145413398743}, {"name": "ask_order_status", "confidence": 0.19960135221481323}, {"name": "ask_return_policy", "confidence": 0.1013963371515274}, {"name": "ask_order_cancel", "confidence": 0.04290151223540306}, {"name": "out_of_scope", "confidence": 0.0390121191740036}, {"name": "ask_international_shipping", "confidence": 0.019348017871379852}, {"name": "ask_track_order", "confidence": 0.017644047737121582}, {"name": "ask_reset_password", "confidence": 0.011530274525284767}, {"name": "ask_shipping_time", "confidence": 0.009417204186320305}, {"name": "greet", "confidence": 0.008837108500301838}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "2db17a3731414e4ebd3881561cb52c4f"}
174	4	user_featurization	1745051011.1480458	\N	\N	{"event": "user_featurization", "timestamp": 1745051011.1480458, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
175	4	action	1745051011.1480458	\N	utter_shipping_time	{"event": "action", "timestamp": 1745051011.1480458, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_shipping_time", "policy": "TEDPolicy", "confidence": 0.9365729689598083, "action_text": null, "hide_rule_turn": false}
176	4	bot	1745051011.1480458	\N	\N	{"event": "bot", "timestamp": 1745051011.1480458, "metadata": {"utter_action": "utter_shipping_time", "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Standard shipping typically takes 3-5 business days. Express shipping is available for 1-2 business day delivery.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
177	4	action	1745051011.1645515	\N	action_listen	{"event": "action", "timestamp": 1745051011.1645515, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.999834418296814, "action_text": null, "hide_rule_turn": false}
251	4	action	1745053129.1669345	\N	action_listen	{"event": "action", "timestamp": 1745053129.1669345, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999905824661255, "action_text": null, "hide_rule_turn": false}
262	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
263	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
178	4	user	1745051144.0780535	ask_order_status	\N	{"event": "user", "timestamp": 1745051144.0780535, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "my order number is ORD-67690 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9991726279258728}, "entities": [{"entity": "order_number", "start": 19, "end": 28, "confidence_entity": 0.9505293965339661, "value": "ORD-67690", "extractor": "DIETClassifier"}], "text": "my order number is ORD-67690 need to know the status", "message_id": "4add196a68e0421ebe6b4ad50fe5b911", "metadata": {}, "text_tokens": [[0, 2], [3, 8], [9, 15], [16, 18], [19, 28], [29, 33], [34, 36], [37, 41], [42, 45], [46, 52]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9991726279258728}, {"name": "ask_reset_password", "confidence": 0.0004320076259318739}, {"name": "greet", "confidence": 8.014386548893526e-05}, {"name": "ask_order_cancel", "confidence": 6.818809197284281e-05}, {"name": "ask_return_policy", "confidence": 6.688961730105802e-05}, {"name": "ask_product_availability", "confidence": 4.844925206271e-05}, {"name": "ask_shipping_time", "confidence": 4.787872967426665e-05}, {"name": "ask_track_order", "confidence": 1.9405732018640265e-05}, {"name": "thank", "confidence": 1.4143291082291398e-05}, {"name": "deny", "confidence": 1.3401637261267751e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "4add196a68e0421ebe6b4ad50fe5b911"}
179	4	slot	1745051144.0780535	\N	order_number	{"event": "slot", "timestamp": 1745051144.0780535, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
180	4	user_featurization	1745051148.354364	\N	\N	{"event": "user_featurization", "timestamp": 1745051148.354364, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
181	4	action	1745051148.354364	\N	action_check_order_status	{"event": "action", "timestamp": 1745051148.354364, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.9988203644752502, "action_text": null, "hide_rule_turn": false}
182	4	bot	1745051148.354364	\N	\N	{"event": "bot", "timestamp": 1745051148.354364, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I couldn't find an order with number ORD-67690. Please check the number and try again.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
183	4	slot	1745051148.354364	\N	order_number	{"event": "slot", "timestamp": 1745051148.354364, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": null}
184	4	action	1745051148.3723657	\N	action_listen	{"event": "action", "timestamp": 1745051148.3723657, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.999782383441925, "action_text": null, "hide_rule_turn": false}
185	4	user	1745051263.4971077	ask_order_cancel	\N	{"event": "user", "timestamp": 1745051263.4971077, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "need to cancel the order ORD-67690", "parse_data": {"intent": {"name": "ask_order_cancel", "confidence": 0.9987666606903076}, "entities": [{"entity": "order_number", "start": 25, "end": 34, "confidence_entity": 0.989105761051178, "value": "ORD-67690", "extractor": "DIETClassifier"}], "text": "need to cancel the order ORD-67690", "message_id": "ac66a9a173614766beb6e751b4c37f2f", "metadata": {}, "text_tokens": [[0, 4], [5, 7], [8, 14], [15, 18], [19, 24], [25, 34]], "intent_ranking": [{"name": "ask_order_cancel", "confidence": 0.9987666606903076}, {"name": "ask_order_status", "confidence": 0.0002485129807610065}, {"name": "ask_return_policy", "confidence": 0.00021640739578288049}, {"name": "ask_international_shipping", "confidence": 0.00015160755719989538}, {"name": "thank", "confidence": 0.00013765205221716315}, {"name": "out_of_scope", "confidence": 9.047937783179805e-05}, {"name": "ask_product_availability", "confidence": 8.432133472524583e-05}, {"name": "ask_track_order", "confidence": 8.021281973924488e-05}, {"name": "deny", "confidence": 5.572720692725852e-05}, {"name": "ask_reset_password", "confidence": 4.979301957064308e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "ac66a9a173614766beb6e751b4c37f2f"}
186	4	slot	1745051263.4971077	\N	order_number	{"event": "slot", "timestamp": 1745051263.4971077, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
187	4	user_featurization	1745051263.529316	\N	\N	{"event": "user_featurization", "timestamp": 1745051263.529316, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
188	4	action	1745051263.529316	\N	action_unlikely_intent	{"event": "action", "timestamp": 1745051263.529316, "metadata": {"query_intent": {"name": "ask_order_cancel", "score": -0.8222946524620056, "threshold": -0.4927312135696411, "severity": 0.3295634388923645}, "ranking": [{"name": "ask_track_order", "score": 0.0056089311838150024, "threshold": -0.22128751873970032, "severity": -0.22689644992351532}, {"name": "ask_order_status", "score": -0.0862930417060852, "threshold": -0.13049501180648804, "severity": -0.04420197010040283}, {"name": "thank", "score": -0.2631468176841736, "threshold": -0.48458972573280334, "severity": -0.22144290804862976}, {"name": "greet", "score": -0.5019625425338745, "threshold": -0.3770428001880646, "severity": 0.12491974234580994}, {"name": "ask_create_account", "score": -0.5685514807701111, "threshold": -0.5867963433265686, "severity": -0.01824486255645752}, {"name": "ask_reset_password", "score": -0.6878615021705627, "threshold": -0.514826238155365, "severity": 0.17303526401519775}, {"name": "goodbye", "score": -0.6963263154029846, "threshold": -0.7157459259033203, "severity": -0.019419610500335693}, {"name": "ask_return_policy", "score": -0.7525952458381653, "threshold": -0.31600886583328247, "severity": 0.4365863800048828}, {"name": "ask_international_shipping", "score": -0.7905045747756958, "threshold": -0.22915658354759216, "severity": 0.5613479614257812}, {"name": "ask_payment_methods", "score": -0.7976529598236084, "threshold": -0.36960339546203613, "severity": 0.42804956436157227}], "model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_unlikely_intent", "policy": "UnexpecTEDIntentPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
264	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
193	4	user	1745051298.682211	ask_order_cancel	\N	{"event": "user", "timestamp": 1745051298.682211, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "need to cancel the order ORD-67690", "parse_data": {"intent": {"name": "ask_order_cancel", "confidence": 0.9987666606903076}, "entities": [{"entity": "order_number", "start": 25, "end": 34, "confidence_entity": 0.989105761051178, "value": "ORD-67690", "extractor": "DIETClassifier"}], "text": "need to cancel the order ORD-67690", "message_id": "d075b0d986454c658692b241448453d0", "metadata": {}, "text_tokens": [[0, 4], [5, 7], [8, 14], [15, 18], [19, 24], [25, 34]], "intent_ranking": [{"name": "ask_order_cancel", "confidence": 0.9987666606903076}, {"name": "ask_order_status", "confidence": 0.0002485129807610065}, {"name": "ask_return_policy", "confidence": 0.00021640739578288049}, {"name": "ask_international_shipping", "confidence": 0.00015160755719989538}, {"name": "thank", "confidence": 0.00013765205221716315}, {"name": "out_of_scope", "confidence": 9.047937783179805e-05}, {"name": "ask_product_availability", "confidence": 8.432133472524583e-05}, {"name": "ask_track_order", "confidence": 8.021281973924488e-05}, {"name": "deny", "confidence": 5.572720692725852e-05}, {"name": "ask_reset_password", "confidence": 4.979301957064308e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "d075b0d986454c658692b241448453d0"}
194	4	slot	1745051298.682211	\N	order_number	{"event": "slot", "timestamp": 1745051298.682211, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
195	4	user_featurization	1745051302.8574712	\N	\N	{"event": "user_featurization", "timestamp": 1745051302.8574712, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
196	4	action	1745051302.8574712	\N	action_list_order_items	{"event": "action", "timestamp": 1745051302.8574712, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_list_order_items", "policy": "TEDPolicy", "confidence": 0.728461503982544, "action_text": null, "hide_rule_turn": false}
197	4	bot	1745051302.8574712	\N	\N	{"event": "bot", "timestamp": 1745051302.8574712, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Here are the items in your order ORD-67690:\\n\\n1. Smartphone X - Quantity: 3, Price: $1277.49, Total: $3832.47\\n2. Digital Camera - Quantity: 1, Price: $559.57, Total: $559.57\\n3. Bluetooth Speaker - Quantity: 1, Price: $67.78, Total: $67.78\\n4. Laptop Pro - Quantity: 3, Price: $1202.31, Total: $3606.93\\n\\nTotal order amount: $8066.75", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
198	4	slot	1745051302.8574712	\N	order_number	{"event": "slot", "timestamp": 1745051302.8574712, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
199	4	action	1745051302.8814692	\N	action_listen	{"event": "action", "timestamp": 1745051302.8814692, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998169541358948, "action_text": null, "hide_rule_turn": false}
200	4	user	1745052159.5905564	greet	\N	{"event": "user", "timestamp": 1745052159.5905564, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "HI", "parse_data": {"intent": {"name": "greet", "confidence": 0.9731400012969971}, "entities": [], "text": "HI", "message_id": "98f3905896ba4220b3169f9edf0caa9a", "metadata": {}, "text_tokens": [[0, 2]], "intent_ranking": [{"name": "greet", "confidence": 0.9731400012969971}, {"name": "goodbye", "confidence": 0.0075219301506876945}, {"name": "affirm", "confidence": 0.005486298818141222}, {"name": "ask_order_cancel", "confidence": 0.0037343509029597044}, {"name": "request_cancel_order", "confidence": 0.0030549103394150734}, {"name": "ask_return_policy", "confidence": 0.0012803509598597884}, {"name": "deny", "confidence": 0.0012050941586494446}, {"name": "confirm_cancel_order", "confidence": 0.0010076571488752961}, {"name": "ask_product_availability", "confidence": 0.0008097938261926174}, {"name": "ask_reset_password", "confidence": 0.000534960301592946}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "98f3905896ba4220b3169f9edf0caa9a"}
201	4	user_featurization	1745052160.6959631	\N	\N	{"event": "user_featurization", "timestamp": 1745052160.6959631, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
202	4	action	1745052160.6959631	\N	utter_greet	{"event": "action", "timestamp": 1745052160.6959631, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_greet", "policy": "TEDPolicy", "confidence": 0.9844194054603577, "action_text": null, "hide_rule_turn": false}
203	4	bot	1745052160.6959631	\N	\N	{"event": "bot", "timestamp": 1745052160.6959631, "metadata": {"utter_action": "utter_greet", "model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Hi there! Welcome to our customer service. What can I assist you with?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
204	4	action	1745052164.8739998	\N	action_get_user_orders	{"event": "action", "timestamp": 1745052164.8739998, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_get_user_orders", "policy": "TEDPolicy", "confidence": 0.5163649320602417, "action_text": null, "hide_rule_turn": false}
205	4	bot	1745052164.8739998	\N	\N	{"event": "bot", "timestamp": 1745052164.8739998, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Here are your recent orders:\\n\\n1. Order #ORD-61833 - Status: processing, Ordered on: March 08, 2025\\n2. Order #ORD-67690 - Status: pending, Ordered on: February 23, 2025\\n3. Order #ORD-94046 - Status: delivered, Ordered on: April 11, 2025\\n4. Order #ORD-51666 - Status: cancelled, Ordered on: April 03, 2025\\n5. Order #ORD-86707 - Status: shipped, Ordered on: March 25, 2025\\n\\n\\nYou can ask about a specific order by providing the order number.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
206	4	action	1745052164.8980606	\N	action_listen	{"event": "action", "timestamp": 1745052164.8980606, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999908208847046, "action_text": null, "hide_rule_turn": false}
207	4	user	1745052201.231392	ask_order_status	\N	{"event": "user", "timestamp": 1745052201.231392, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "may I know my order status for the order id ORD-67690", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9997124075889587}, "entities": [{"entity": "order_number", "start": 44, "end": 53, "confidence_entity": 0.9987004995346069, "value": "ORD-67690", "extractor": "DIETClassifier"}], "text": "may I know my order status for the order id ORD-67690", "message_id": "863d4111d8e445e5a5db6ec96a697d5c", "metadata": {}, "text_tokens": [[0, 3], [4, 5], [6, 10], [11, 13], [14, 19], [20, 26], [27, 30], [31, 34], [35, 40], [41, 42], [42, 43], [44, 53]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9997124075889587}, {"name": "request_cancel_order", "confidence": 7.966403791215271e-05}, {"name": "ask_order_items", "confidence": 7.568061846541241e-05}, {"name": "ask_reset_password", "confidence": 3.67051106877625e-05}, {"name": "ask_shipping_time", "confidence": 2.7924548703595065e-05}, {"name": "ask_payment_methods", "confidence": 1.329539645666955e-05}, {"name": "ask_return_policy", "confidence": 8.572021215513814e-06}, {"name": "out_of_scope", "confidence": 8.303028153022751e-06}, {"name": "ask_create_account", "confidence": 7.420092515530996e-06}, {"name": "goodbye", "confidence": 6.68554912408581e-06}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "863d4111d8e445e5a5db6ec96a697d5c"}
208	4	slot	1745052201.231392	\N	order_number	{"event": "slot", "timestamp": 1745052201.231392, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
209	4	user_featurization	1745052205.4136553	\N	\N	{"event": "user_featurization", "timestamp": 1745052205.4136553, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
210	4	action	1745052205.4136553	\N	action_check_order_status	{"event": "action", "timestamp": 1745052205.4136553, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.9937106370925903, "action_text": null, "hide_rule_turn": false}
211	4	bot	1745052205.4136553	\N	\N	{"event": "bot", "timestamp": 1745052205.4136553, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Your order ORD-67690 is pending. We're processing it now. Estimated delivery: March 08, 2025.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
212	4	slot	1745052205.4136553	\N	order_number	{"event": "slot", "timestamp": 1745052205.4136553, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
213	4	action	1745052205.4376554	\N	action_listen	{"event": "action", "timestamp": 1745052205.4376554, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999908208847046, "action_text": null, "hide_rule_turn": false}
214	4	user	1745052225.3897674	nlu_fallback	\N	{"event": "user", "timestamp": 1745052225.3897674, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "can you cancel the order", "parse_data": {"intent": {"name": "nlu_fallback", "confidence": 0.7}, "entities": [], "text": "can you cancel the order", "message_id": "9b45c907956f48788e6226cedb79e222", "metadata": {}, "text_tokens": [[0, 3], [4, 7], [8, 14], [15, 18], [19, 24]], "intent_ranking": [{"name": "nlu_fallback", "confidence": 0.7}, {"name": "request_cancel_order", "confidence": 0.4619091749191284}, {"name": "ask_order_cancel", "confidence": 0.22248993813991547}, {"name": "confirm_cancel_order", "confidence": 0.09198527783155441}, {"name": "ask_shipping_time", "confidence": 0.04166383668780327}, {"name": "ask_payment_methods", "confidence": 0.030303554609417915}, {"name": "provide_email", "confidence": 0.027391964569687843}, {"name": "thank", "confidence": 0.02413778565824032}, {"name": "ask_international_shipping", "confidence": 0.01985931023955345}, {"name": "greet", "confidence": 0.015843398869037628}, {"name": "goodbye", "confidence": 0.014945752918720245}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "9b45c907956f48788e6226cedb79e222"}
215	4	user_featurization	1745052225.4221046	\N	\N	{"event": "user_featurization", "timestamp": 1745052225.4221046, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
216	4	action	1745052225.4221046	\N	utter_thank	{"event": "action", "timestamp": 1745052225.4221046, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_thank", "policy": "TEDPolicy", "confidence": 0.47558844089508057, "action_text": null, "hide_rule_turn": false}
217	4	bot	1745052225.4221046	\N	\N	{"event": "bot", "timestamp": 1745052225.4221046, "metadata": {"utter_action": "utter_thank", "model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "No problem at all! Feel free to ask if you have other questions.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
218	4	action	1745052225.44665	\N	action_listen	{"event": "action", "timestamp": 1745052225.44665, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.999992847442627, "action_text": null, "hide_rule_turn": false}
252	4	action	1745064927.6464815	\N	action_session_start	{"event": "action", "timestamp": 1745064927.6464815, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_session_start", "policy": null, "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
253	4	session_started	1745064927.6464815	\N	\N	{"event": "session_started", "timestamp": 1745064927.6464815, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}}
254	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
255	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
219	4	user	1745052250.2728865	request_cancel_order	\N	{"event": "user", "timestamp": 1745052250.2728865, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "cancel the order ORD-67690", "parse_data": {"intent": {"name": "request_cancel_order", "confidence": 0.8671186566352844}, "entities": [{"entity": "order_number", "start": 17, "end": 26, "confidence_entity": 0.999290943145752, "value": "ORD-67690", "extractor": "DIETClassifier"}], "text": "cancel the order ORD-67690", "message_id": "c9140b4dd95f4fdbac4f6bf97d1b763e", "metadata": {}, "text_tokens": [[0, 6], [7, 10], [11, 16], [17, 26]], "intent_ranking": [{"name": "request_cancel_order", "confidence": 0.8671186566352844}, {"name": "ask_order_status", "confidence": 0.08645789325237274}, {"name": "ask_order_cancel", "confidence": 0.014292579144239426}, {"name": "greet", "confidence": 0.007450454868376255}, {"name": "ask_shipping_time", "confidence": 0.005124493967741728}, {"name": "provide_email", "confidence": 0.0042187925428152084}, {"name": "ask_order_items", "confidence": 0.003599955700337887}, {"name": "confirm_cancel_order", "confidence": 0.0026686727069318295}, {"name": "ask_return_policy", "confidence": 0.001692828955128789}, {"name": "ask_track_order", "confidence": 0.0013980672229081392}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "c9140b4dd95f4fdbac4f6bf97d1b763e"}
220	4	slot	1745052250.2728865	\N	order_number	{"event": "slot", "timestamp": 1745052250.2728865, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
221	4	user_featurization	1745052252.4539008	\N	\N	{"event": "user_featurization", "timestamp": 1745052252.4539008, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
222	4	action	1745052252.4539008	\N	action_cancel_order	{"event": "action", "timestamp": 1745052252.4539008, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_cancel_order", "policy": "TEDPolicy", "confidence": 0.9840800166130066, "action_text": null, "hide_rule_turn": false}
223	4	bot	1745052252.4539008	\N	\N	{"event": "bot", "timestamp": 1745052252.4539008, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Are you sure you want to cancel order #ORD-67690? This action cannot be undone.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
224	4	bot	1745052252.4539008	\N	\N	{"event": "bot", "timestamp": 1745052252.4539008, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Please reply with 'Yes, cancel the order' to confirm or 'No' to keep the order.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
225	4	slot	1745052252.4539008	\N	confirm_cancel	{"event": "slot", "timestamp": 1745052252.4539008, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "asked"}
226	4	action	1745052252.4861944	\N	action_listen	{"event": "action", "timestamp": 1745052252.4861944, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.999961256980896, "action_text": null, "hide_rule_turn": false}
227	4	user	1745052266.2543354	affirm	\N	{"event": "user", "timestamp": 1745052266.2543354, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "yes", "parse_data": {"intent": {"name": "affirm", "confidence": 0.9210737943649292}, "entities": [], "text": "yes", "message_id": "267103b0edab4615a3e6ec41a06a793b", "metadata": {}, "text_tokens": [[0, 3]], "intent_ranking": [{"name": "affirm", "confidence": 0.9210737943649292}, {"name": "deny", "confidence": 0.04245093837380409}, {"name": "confirm_cancel_order", "confidence": 0.009786538779735565}, {"name": "greet", "confidence": 0.007014828734099865}, {"name": "ask_shipping_time", "confidence": 0.004263848066329956}, {"name": "ask_return_policy", "confidence": 0.00406078714877367}, {"name": "ask_create_account", "confidence": 0.003276379546150565}, {"name": "ask_order_items", "confidence": 0.0016330144135281444}, {"name": "goodbye", "confidence": 0.0010419017635285854}, {"name": "thank", "confidence": 0.0009790781186893582}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "267103b0edab4615a3e6ec41a06a793b"}
228	4	user_featurization	1745052266.3029768	\N	\N	{"event": "user_featurization", "timestamp": 1745052266.3029768, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
229	4	action	1745052266.3029768	\N	utter_goodbye	{"event": "action", "timestamp": 1745052266.3029768, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_goodbye", "policy": "TEDPolicy", "confidence": 0.37035706639289856, "action_text": null, "hide_rule_turn": false}
230	4	bot	1745052266.3029768	\N	\N	{"event": "bot", "timestamp": 1745052266.3029768, "metadata": {"utter_action": "utter_goodbye", "model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Thanks for chatting! I'll be here if you need more help later.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
231	4	action	1745052266.3271806	\N	action_listen	{"event": "action", "timestamp": 1745052266.3271806, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.999941349029541, "action_text": null, "hide_rule_turn": false}
256	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
257	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
258	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
259	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
232	4	user	1745053100.752894	request_cancel_order	\N	{"event": "user", "timestamp": 1745053100.752894, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "text": "cancel the order ORD-67690", "parse_data": {"intent": {"name": "request_cancel_order", "confidence": 0.8738809823989868}, "entities": [{"entity": "order_number", "start": 17, "end": 26, "confidence_entity": 0.9994939565658569, "value": "ORD-67690", "extractor": "DIETClassifier"}], "text": "cancel the order ORD-67690", "message_id": "da1324409b464ba1ae3b83b164ec2120", "metadata": {}, "text_tokens": [[0, 6], [7, 10], [11, 16], [17, 26]], "intent_ranking": [{"name": "request_cancel_order", "confidence": 0.8738809823989868}, {"name": "ask_order_cancel", "confidence": 0.05814942345023155}, {"name": "ask_order_status", "confidence": 0.01807877980172634}, {"name": "confirm_cancel_order", "confidence": 0.013881622813642025}, {"name": "provide_email", "confidence": 0.0055258371867239475}, {"name": "out_of_scope", "confidence": 0.005201315972954035}, {"name": "ask_reset_password", "confidence": 0.005029377061873674}, {"name": "ask_create_account", "confidence": 0.004629235714673996}, {"name": "ask_payment_methods", "confidence": 0.004004239570349455}, {"name": "greet", "confidence": 0.0025385988410562277}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "da1324409b464ba1ae3b83b164ec2120"}
233	4	slot	1745053100.752894	\N	order_number	{"event": "slot", "timestamp": 1745053100.752894, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
234	4	user_featurization	1745053103.9071777	\N	\N	{"event": "user_featurization", "timestamp": 1745053103.9071777, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
235	4	action	1745053103.9071777	\N	action_cancel_order	{"event": "action", "timestamp": 1745053103.9071777, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_cancel_order", "policy": "TEDPolicy", "confidence": 0.9724991917610168, "action_text": null, "hide_rule_turn": false}
236	4	bot	1745053103.9071777	\N	\N	{"event": "bot", "timestamp": 1745053103.9071777, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Are you sure you want to cancel order #ORD-67690? This action cannot be undone.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
237	4	bot	1745053103.9071777	\N	\N	{"event": "bot", "timestamp": 1745053103.9071777, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Please reply with 'Yes, cancel the order' to confirm or 'No' to keep the order.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
238	4	slot	1745053103.9071777	\N	confirm_cancel	{"event": "slot", "timestamp": 1745053103.9071777, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "asked"}
239	4	action	1745053103.932481	\N	action_listen	{"event": "action", "timestamp": 1745053103.932481, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9997674822807312, "action_text": null, "hide_rule_turn": false}
240	4	user	1745053122.8313344	affirm	\N	{"event": "user", "timestamp": 1745053122.8313344, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "text": "yes", "parse_data": {"intent": {"name": "affirm", "confidence": 0.954651415348053}, "entities": [], "text": "yes", "message_id": "8d5435f7357849a3bef45cf7e856e4c7", "metadata": {}, "text_tokens": [[0, 3]], "intent_ranking": [{"name": "affirm", "confidence": 0.954651415348053}, {"name": "confirm_cancel_order", "confidence": 0.024264907464385033}, {"name": "deny", "confidence": 0.004865166265517473}, {"name": "ask_payment_methods", "confidence": 0.0030380594544112682}, {"name": "thank", "confidence": 0.002319740829989314}, {"name": "ask_international_shipping", "confidence": 0.0014654929982498288}, {"name": "ask_product_availability", "confidence": 0.0014240979216992855}, {"name": "greet", "confidence": 0.0012522611068561673}, {"name": "ask_track_order", "confidence": 0.000988781452178955}, {"name": "ask_reset_password", "confidence": 0.0009845002787187696}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "8d5435f7357849a3bef45cf7e856e4c7"}
241	4	user_featurization	1745053122.872374	\N	\N	{"event": "user_featurization", "timestamp": 1745053122.872374, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
242	4	action	1745053122.872374	\N	action_unlikely_intent	{"event": "action", "timestamp": 1745053122.872374, "metadata": {"query_intent": {"name": "affirm", "score": -0.045696571469306946, "threshold": 0.07670283317565918, "severity": 0.12239940464496613}, "ranking": [{"name": "confirm_cancel_order", "score": 0.1299591213464737, "threshold": 0.2496713101863861, "severity": 0.11971218883991241}, {"name": "affirm", "score": -0.045696571469306946, "threshold": 0.07670283317565918, "severity": 0.12239940464496613}, {"name": "deny", "score": -0.21824124455451965, "threshold": -0.08335316181182861, "severity": 0.13488808274269104}, {"name": "ask_order_items", "score": -0.9570311307907104, "threshold": -0.6459304094314575, "severity": 0.31110072135925293}, {"name": "thank", "score": -1.0052942037582397, "threshold": -0.5931546092033386, "severity": 0.4121395945549011}, {"name": "provide_email", "score": -1.1229043006896973, "threshold": -0.8972034454345703, "severity": 0.22570085525512695}, {"name": "ask_product_availability", "score": -1.1398839950561523, "threshold": null, "severity": null}, {"name": "ask_order_status", "score": -1.1419237852096558, "threshold": -0.2440904676914215, "severity": 0.8978333473205566}, {"name": "request_cancel_order", "score": -1.2491693496704102, "threshold": -0.3273521959781647, "severity": 0.9218171834945679}, {"name": "ask_international_shipping", "score": -1.3435449600219727, "threshold": -0.7336319088935852, "severity": 0.6099130511283875}], "model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_unlikely_intent", "policy": "UnexpecTEDIntentPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
243	4	action	1745053124.984298	\N	action_handle_cancel_confirmation	{"event": "action", "timestamp": 1745053124.984298, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_handle_cancel_confirmation", "policy": "TEDPolicy", "confidence": 0.9301419258117676, "action_text": null, "hide_rule_turn": false}
265	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
266	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
267	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
268	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
269	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
270	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
271	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
272	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
273	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
274	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
275	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
276	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": null}
277	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
278	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": null}
279	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
280	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
281	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
282	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
283	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
284	4	slot	1745064927.6464815	\N	confirm_cancel	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "asked"}
285	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
286	4	slot	1745064927.6464815	\N	confirm_cancel	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "asked"}
287	4	slot	1745064927.6464815	\N	confirm_cancel	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "confirmed"}
288	4	slot	1745064927.6464815	\N	order_number	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
289	4	slot	1745064927.6464815	\N	confirm_cancel	{"event": "slot", "timestamp": 1745064927.6464815, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": null}
290	4	action	1745064927.6464815	\N	action_listen	{"event": "action", "timestamp": 1745064927.6464815, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": null, "confidence": null, "action_text": null, "hide_rule_turn": false}
313	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
314	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
291	4	user	1745064928.5935836	ask_order_status	\N	{"event": "user", "timestamp": 1745064928.5935836, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I want to know status for the order number ORD-523CAAAA", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9971674084663391}, "entities": [{"entity": "order_number", "start": 43, "end": 55, "confidence_entity": 0.7865554094314575, "value": "ORD-523CAAAA", "extractor": "DIETClassifier"}], "text": "I want to know status for the order number ORD-523CAAAA", "message_id": "d88c5828ce2849c8942df81de1d3b2eb", "metadata": {}, "text_tokens": [[0, 1], [2, 6], [7, 9], [10, 14], [15, 21], [22, 25], [26, 29], [30, 35], [36, 42], [43, 55]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9971674084663391}, {"name": "greet", "confidence": 0.0011403575772419572}, {"name": "ask_reset_password", "confidence": 0.00041219015838578343}, {"name": "ask_create_account", "confidence": 0.0003328027087263763}, {"name": "provide_email", "confidence": 0.00032395165180787444}, {"name": "out_of_scope", "confidence": 0.00017581463907845318}, {"name": "request_cancel_order", "confidence": 0.00014289769751485437}, {"name": "ask_payment_methods", "confidence": 6.174157897476107e-05}, {"name": "ask_shipping_time", "confidence": 5.6684228184167296e-05}, {"name": "goodbye", "confidence": 3.860356082441285e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "d88c5828ce2849c8942df81de1d3b2eb"}
292	4	slot	1745064928.6090555	\N	order_number	{"event": "slot", "timestamp": 1745064928.6090555, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-523CAAAA"}
293	4	user_featurization	1745064933.9484322	\N	\N	{"event": "user_featurization", "timestamp": 1745064933.9484322, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
294	4	action	1745064933.9484322	\N	action_check_order_status	{"event": "action", "timestamp": 1745064933.9484322, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.9891988635063171, "action_text": null, "hide_rule_turn": false}
295	4	bot	1745064933.9484322	\N	\N	{"event": "bot", "timestamp": 1745064933.9484322, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Your order ORD-523CAAAA has been delivered. If you haven't received it, please contact our support team.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
296	4	slot	1745064933.9484322	\N	order_number	{"event": "slot", "timestamp": 1745064933.9484322, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-523CAAAA"}
297	4	action	1745064933.9630773	\N	action_listen	{"event": "action", "timestamp": 1745064933.9630773, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999904632568359, "action_text": null, "hide_rule_turn": false}
298	4	action	1745068610.2508717	\N	action_session_start	{"event": "action", "timestamp": 1745068610.2508717, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_session_start", "policy": null, "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
299	4	session_started	1745068610.2508717	\N	\N	{"event": "session_started", "timestamp": 1745068610.2508717, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}}
300	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
301	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
302	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
303	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
304	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
305	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
306	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
307	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
308	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
309	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
310	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
311	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
312	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
315	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
316	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
317	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
318	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
319	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
320	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
321	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
322	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": null}
323	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
324	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": null}
325	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
326	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
327	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
328	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
329	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
330	4	slot	1745068610.2508717	\N	confirm_cancel	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "asked"}
331	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
332	4	slot	1745068610.2508717	\N	confirm_cancel	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "asked"}
333	4	slot	1745068610.2508717	\N	confirm_cancel	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "confirmed"}
334	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
335	4	slot	1745068610.2508717	\N	confirm_cancel	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": null}
336	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-523CAAAA"}
337	4	slot	1745068610.2508717	\N	order_number	{"event": "slot", "timestamp": 1745068610.2508717, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-523CAAAA"}
338	4	action	1745068610.2508717	\N	action_listen	{"event": "action", "timestamp": 1745068610.2508717, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": null, "confidence": null, "action_text": null, "hide_rule_turn": false}
352	4	bot	1745068662.4712584	\N	\N	{"event": "bot", "timestamp": 1745068662.4712584, "metadata": {"utter_action": "utter_ask_order_items_without_number", "model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'd be happy to check the items in your order. Could you please provide your order number?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
353	4	action	1745068662.4801672	\N	action_listen	{"event": "action", "timestamp": 1745068662.4801672, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999321699142456, "action_text": null, "hide_rule_turn": false}
387	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
339	4	user	1745068611.2004006	nlu_fallback	\N	{"event": "user", "timestamp": 1745068611.2004006, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Hi, how to place order", "parse_data": {"intent": {"name": "nlu_fallback", "confidence": 0.7}, "entities": [], "text": "Hi, how to place order", "message_id": "9993cc748c23478bb56513c69f6bfae6", "metadata": {}, "text_tokens": [[0, 2], [2, 3], [4, 7], [8, 10], [11, 16], [17, 22]], "intent_ranking": [{"name": "nlu_fallback", "confidence": 0.7}, {"name": "ask_order_cancel", "confidence": 0.5427498817443848}, {"name": "request_cancel_order", "confidence": 0.18662482500076294}, {"name": "ask_create_account", "confidence": 0.0555100180208683}, {"name": "ask_order_status", "confidence": 0.047683898359537125}, {"name": "greet", "confidence": 0.04445493966341019}, {"name": "confirm_cancel_order", "confidence": 0.029344432055950165}, {"name": "ask_track_order", "confidence": 0.025722021237015724}, {"name": "ask_reset_password", "confidence": 0.01089868601411581}, {"name": "ask_product_availability", "confidence": 0.00972851924598217}, {"name": "deny", "confidence": 0.008206645958125591}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "9993cc748c23478bb56513c69f6bfae6"}
340	4	user_featurization	1745068612.5420086	\N	\N	{"event": "user_featurization", "timestamp": 1745068612.5420086, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
341	4	action	1745068612.5420086	\N	utter_goodbye	{"event": "action", "timestamp": 1745068612.5420086, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_goodbye", "policy": "TEDPolicy", "confidence": 0.8330284357070923, "action_text": null, "hide_rule_turn": false}
342	4	bot	1745068612.5420086	\N	\N	{"event": "bot", "timestamp": 1745068612.5420086, "metadata": {"utter_action": "utter_goodbye", "model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Thanks for chatting! I'll be here if you need more help later.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
343	4	action	1745068612.5502884	\N	action_listen	{"event": "action", "timestamp": 1745068612.5502884, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998548030853271, "action_text": null, "hide_rule_turn": false}
344	4	user	1745068639.1752584	nlu_fallback	\N	{"event": "user", "timestamp": 1745068639.1752584, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "how to place order", "parse_data": {"intent": {"name": "nlu_fallback", "confidence": 0.7}, "entities": [], "text": "how to place order", "message_id": "c2aff5e91ddd4079ab7e03814968a684", "metadata": {}, "text_tokens": [[0, 3], [4, 6], [7, 12], [13, 18]], "intent_ranking": [{"name": "nlu_fallback", "confidence": 0.7}, {"name": "ask_order_cancel", "confidence": 0.6783537864685059}, {"name": "goodbye", "confidence": 0.09606920927762985}, {"name": "request_cancel_order", "confidence": 0.08499959111213684}, {"name": "ask_order_status", "confidence": 0.04025440663099289}, {"name": "ask_create_account", "confidence": 0.03366206958889961}, {"name": "ask_track_order", "confidence": 0.017324576154351234}, {"name": "ask_order_items", "confidence": 0.010628480464220047}, {"name": "ask_reset_password", "confidence": 0.006691306829452515}, {"name": "deny", "confidence": 0.0066636595875024796}, {"name": "out_of_scope", "confidence": 0.006402209401130676}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "c2aff5e91ddd4079ab7e03814968a684"}
345	4	user_featurization	1745068639.2003765	\N	\N	{"event": "user_featurization", "timestamp": 1745068639.2003765, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
346	4	action	1745068639.2003765	\N	utter_goodbye	{"event": "action", "timestamp": 1745068639.2003765, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_goodbye", "policy": "TEDPolicy", "confidence": 0.8184680342674255, "action_text": null, "hide_rule_turn": false}
347	4	bot	1745068639.2003765	\N	\N	{"event": "bot", "timestamp": 1745068639.2003765, "metadata": {"utter_action": "utter_goodbye", "model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Have a great day! Come back anytime you need assistance.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
348	4	action	1745068639.2099998	\N	action_listen	{"event": "action", "timestamp": 1745068639.2099998, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998764991760254, "action_text": null, "hide_rule_turn": false}
349	4	user	1745068662.446658	ask_order_items	\N	{"event": "user", "timestamp": 1745068662.446658, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "list items", "parse_data": {"intent": {"name": "ask_order_items", "confidence": 0.9951075315475464}, "entities": [], "text": "list items", "message_id": "33821aa2ac944fb5ac03dc9ad579beb7", "metadata": {}, "text_tokens": [[0, 4], [5, 10]], "intent_ranking": [{"name": "ask_order_items", "confidence": 0.9951075315475464}, {"name": "thank", "confidence": 0.001329874969087541}, {"name": "out_of_scope", "confidence": 0.0006586771924048662}, {"name": "deny", "confidence": 0.0006046428461559117}, {"name": "ask_shipping_time", "confidence": 0.000575183832552284}, {"name": "goodbye", "confidence": 0.00041272537782788277}, {"name": "ask_return_policy", "confidence": 0.00025055560399778187}, {"name": "confirm_cancel_order", "confidence": 0.0002261516056023538}, {"name": "ask_payment_methods", "confidence": 0.00019466300727799535}, {"name": "ask_product_availability", "confidence": 0.00017413772002328187}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "33821aa2ac944fb5ac03dc9ad579beb7"}
350	4	user_featurization	1745068662.4712584	\N	\N	{"event": "user_featurization", "timestamp": 1745068662.4712584, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
351	4	action	1745068662.4712584	\N	utter_ask_order_items_without_number	{"event": "action", "timestamp": 1745068662.4712584, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_ask_order_items_without_number", "policy": "TEDPolicy", "confidence": 0.9445486068725586, "action_text": null, "hide_rule_turn": false}
354	4	user	1745068692.7550123	ask_order_status	\N	{"event": "user", "timestamp": 1745068692.7550123, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Order #ORD-61833", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9639613032341003}, "entities": [{"entity": "order_number", "start": 6, "end": 7, "confidence_entity": 0.9531266689300537, "value": "#", "extractor": "DIETClassifier"}, {"entity": "order_number", "start": 7, "end": 16, "confidence_entity": 0.9910734295845032, "value": "ORD-61833", "extractor": "DIETClassifier"}], "text": "Order #ORD-61833", "message_id": "b564eef7ae9840c6973c4ba61571f26a", "metadata": {}, "text_tokens": [[0, 5], [6, 7], [7, 16]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9639613032341003}, {"name": "request_cancel_order", "confidence": 0.01355762593448162}, {"name": "provide_email", "confidence": 0.004445299971848726}, {"name": "goodbye", "confidence": 0.0028300166595727205}, {"name": "ask_payment_methods", "confidence": 0.002456934889778495}, {"name": "ask_order_cancel", "confidence": 0.0022718319669365883}, {"name": "ask_reset_password", "confidence": 0.002131435554474592}, {"name": "ask_order_items", "confidence": 0.0021118829026818275}, {"name": "out_of_scope", "confidence": 0.002105770166963339}, {"name": "ask_create_account", "confidence": 0.0012938929721713066}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "b564eef7ae9840c6973c4ba61571f26a"}
355	4	slot	1745068692.7550123	\N	order_number	{"event": "slot", "timestamp": 1745068692.7550123, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
356	4	user_featurization	1745068696.9298193	\N	\N	{"event": "user_featurization", "timestamp": 1745068696.9298193, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
357	4	action	1745068696.9298193	\N	action_check_order_status	{"event": "action", "timestamp": 1745068696.9298193, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.9831462502479553, "action_text": null, "hide_rule_turn": false}
358	4	bot	1745068696.9298193	\N	\N	{"event": "bot", "timestamp": 1745068696.9298193, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Your order ORD-61833 is being processed. Estimated delivery: March 19, 2025.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
359	4	slot	1745068696.9298193	\N	order_number	{"event": "slot", "timestamp": 1745068696.9298193, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
360	4	action	1745068696.9496949	\N	action_listen	{"event": "action", "timestamp": 1745068696.9496949, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999102354049683, "action_text": null, "hide_rule_turn": false}
361	4	user	1745070118.3253555	ask_order_status	\N	{"event": "user", "timestamp": 1745070118.3253555, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "What's my order status?", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9994257688522339}, "entities": [], "text": "What's my order status?", "message_id": "e0e127e1142f4e97bd1f21afc6d6bc6d", "metadata": {}, "text_tokens": [[0, 4], [4, 6], [7, 9], [10, 15], [16, 22], [22, 23]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9994257688522339}, {"name": "greet", "confidence": 0.00016164923727046698}, {"name": "provide_email", "confidence": 0.00015594834985677153}, {"name": "out_of_scope", "confidence": 7.597944932058454e-05}, {"name": "ask_reset_password", "confidence": 6.887226481921971e-05}, {"name": "ask_create_account", "confidence": 2.017670158238616e-05}, {"name": "ask_payment_methods", "confidence": 1.564268495712895e-05}, {"name": "ask_shipping_time", "confidence": 1.2513049114204478e-05}, {"name": "request_cancel_order", "confidence": 1.2182116734038573e-05}, {"name": "affirm", "confidence": 1.1563257430680096e-05}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "e0e127e1142f4e97bd1f21afc6d6bc6d"}
362	4	user_featurization	1745070118.349521	\N	\N	{"event": "user_featurization", "timestamp": 1745070118.349521, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
363	4	action	1745070118.349521	\N	utter_ask_order_status_without_number	{"event": "action", "timestamp": 1745070118.349521, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_ask_order_status_without_number", "policy": "TEDPolicy", "confidence": 0.9777242541313171, "action_text": null, "hide_rule_turn": false}
364	4	bot	1745070118.349521	\N	\N	{"event": "bot", "timestamp": 1745070118.349521, "metadata": {"utter_action": "utter_ask_order_status_without_number", "model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I'd be happy to check your order status. Could you please provide your order number?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
365	4	action	1745070118.3691726	\N	action_listen	{"event": "action", "timestamp": 1745070118.3691726, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999347925186157, "action_text": null, "hide_rule_turn": false}
366	5	action	1745076875.1812303	\N	action_session_start	{"event": "action", "timestamp": 1745076875.1812303, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_session_start", "policy": null, "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
367	5	session_started	1745076875.1812303	\N	\N	{"event": "session_started", "timestamp": 1745076875.1812303, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}}
368	5	action	1745076875.1812303	\N	action_listen	{"event": "action", "timestamp": 1745076875.1812303, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": null, "confidence": null, "action_text": null, "hide_rule_turn": false}
386	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
369	5	user	1745076875.2187657	ask_track_order	\N	{"event": "user", "timestamp": 1745076875.2187657, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "How can I track my order?", "parse_data": {"intent": {"name": "ask_track_order", "confidence": 0.9947807192802429}, "entities": [], "text": "How can I track my order?", "message_id": "c0819af5d92c4a129d8b58fbced1aab5", "metadata": {}, "text_tokens": [[0, 3], [4, 7], [8, 9], [10, 15], [16, 18], [19, 24], [24, 25]], "intent_ranking": [{"name": "ask_track_order", "confidence": 0.9947807192802429}, {"name": "ask_order_status", "confidence": 0.0015644343802705407}, {"name": "ask_order_cancel", "confidence": 0.0010568446014076471}, {"name": "goodbye", "confidence": 0.0006178189069032669}, {"name": "provide_email", "confidence": 0.0003302122640889138}, {"name": "greet", "confidence": 0.000304237735690549}, {"name": "ask_payment_methods", "confidence": 0.000280764332273975}, {"name": "affirm", "confidence": 0.000219543362618424}, {"name": "ask_product_availability", "confidence": 0.00019967378466390073}, {"name": "ask_create_account", "confidence": 0.00016019027680158615}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "c0819af5d92c4a129d8b58fbced1aab5"}
370	5	user_featurization	1745076875.2347655	\N	\N	{"event": "user_featurization", "timestamp": 1745076875.2347655, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
371	5	action	1745076875.2347655	\N	utter_ask_track_order_without_number	{"event": "action", "timestamp": 1745076875.2347655, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_ask_track_order_without_number", "policy": "MemoizationPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
372	5	bot	1745076875.2347655	\N	\N	{"event": "bot", "timestamp": 1745076875.2347655, "metadata": {"utter_action": "utter_ask_track_order_without_number", "model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "I can help you track your order. Please provide your order number so I can look it up.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
373	5	action	1745076875.2420928	\N	action_listen	{"event": "action", "timestamp": 1745076875.2420928, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "MemoizationPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
374	5	user	1745076908.5894015	ask_order_cancel	\N	{"event": "user", "timestamp": 1745076908.5894015, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "How to place an order", "parse_data": {"intent": {"name": "ask_order_cancel", "confidence": 0.9468894004821777}, "entities": [], "text": "How to place an order", "message_id": "3bed1441f1ce46199b2ca532774ece70", "metadata": {}, "text_tokens": [[0, 3], [4, 6], [7, 12], [13, 15], [16, 21]], "intent_ranking": [{"name": "ask_order_cancel", "confidence": 0.9468894004821777}, {"name": "request_cancel_order", "confidence": 0.011627145111560822}, {"name": "ask_create_account", "confidence": 0.009954993613064289}, {"name": "ask_order_status", "confidence": 0.007950160652399063}, {"name": "ask_track_order", "confidence": 0.007567918859422207}, {"name": "goodbye", "confidence": 0.006973091047257185}, {"name": "deny", "confidence": 0.0035370069090276957}, {"name": "ask_order_items", "confidence": 0.001479237456806004}, {"name": "ask_product_availability", "confidence": 0.001022655051201582}, {"name": "ask_reset_password", "confidence": 0.0007674855878576636}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "3bed1441f1ce46199b2ca532774ece70"}
375	5	user_featurization	1745076908.6059573	\N	\N	{"event": "user_featurization", "timestamp": 1745076908.6059573, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
376	5	action	1745076908.6059573	\N	utter_order_cancel	{"event": "action", "timestamp": 1745076908.6059573, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_order_cancel", "policy": "TEDPolicy", "confidence": 0.906589150428772, "action_text": null, "hide_rule_turn": false}
377	5	bot	1745076908.606958	\N	\N	{"event": "bot", "timestamp": 1745076908.606958, "metadata": {"utter_action": "utter_order_cancel", "model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "You can cancel an order within 24 hours of placing it if it hasn't shipped yet. Would you like me to help you cancel an order?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
378	5	action	1745076908.6149879	\N	action_listen	{"event": "action", "timestamp": 1745076908.6149879, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999158382415771, "action_text": null, "hide_rule_turn": false}
379	4	action	1745081242.6537006	\N	action_session_start	{"event": "action", "timestamp": 1745081242.6537006, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_session_start", "policy": null, "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
380	4	session_started	1745081242.6610174	\N	\N	{"event": "session_started", "timestamp": 1745081242.6610174, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}}
381	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
382	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
383	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
384	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
385	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
388	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
389	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
390	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
391	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
392	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
393	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
394	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
395	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
396	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
397	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
398	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
399	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-51666"}
400	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
401	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
402	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
403	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": null}
404	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
405	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": null}
406	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
407	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "b0a564ff3f0d4c509a716399d8a608fe", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
408	4	slot	1745081242.6613605	\N	order_number	{"event": "slot", "timestamp": 1745081242.6613605, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
409	4	slot	1745081242.66148	\N	order_number	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
410	4	slot	1745081242.66148	\N	order_number	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
411	4	slot	1745081242.66148	\N	confirm_cancel	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "18b63c1e68604236b58cf8217ebef256", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "asked"}
412	4	slot	1745081242.66148	\N	order_number	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
413	4	slot	1745081242.66148	\N	confirm_cancel	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "asked"}
414	4	slot	1745081242.66148	\N	confirm_cancel	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": "confirmed"}
415	4	slot	1745081242.66148	\N	order_number	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-67690"}
416	4	slot	1745081242.66148	\N	confirm_cancel	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "confirm_cancel", "value": null}
417	4	slot	1745081242.66148	\N	order_number	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-523CAAAA"}
418	4	slot	1745081242.66148	\N	order_number	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "5975a2057c274d9d8a415411f1be2794", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-523CAAAA"}
419	4	slot	1745081242.66148	\N	order_number	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
420	4	slot	1745081242.66148	\N	order_number	{"event": "slot", "timestamp": 1745081242.66148, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
421	4	action	1745081242.66148	\N	action_listen	{"event": "action", "timestamp": 1745081242.66148, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": null, "confidence": null, "action_text": null, "hide_rule_turn": false}
422	4	user	1745081243.8124113	greet	\N	{"event": "user", "timestamp": 1745081243.8124113, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "hi", "parse_data": {"intent": {"name": "greet", "confidence": 0.9901424646377563}, "entities": [], "text": "hi", "message_id": "fa3dd829555c442897a175d9847d3689", "metadata": {}, "text_tokens": [[0, 2]], "intent_ranking": [{"name": "greet", "confidence": 0.9901424646377563}, {"name": "deny", "confidence": 0.0018220765050500631}, {"name": "out_of_scope", "confidence": 0.0012130957329645753}, {"name": "ask_international_shipping", "confidence": 0.0012111375108361244}, {"name": "ask_order_status", "confidence": 0.0008249254897236824}, {"name": "ask_create_account", "confidence": 0.000716641778126359}, {"name": "thank", "confidence": 0.0007061943761073053}, {"name": "confirm_cancel_order", "confidence": 0.000547553994692862}, {"name": "ask_reset_password", "confidence": 0.0005446463474072516}, {"name": "ask_product_availability", "confidence": 0.0005425310228019953}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "fa3dd829555c442897a175d9847d3689"}
423	4	user_featurization	1745081244.9942884	\N	\N	{"event": "user_featurization", "timestamp": 1745081244.9942884, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
424	4	action	1745081244.9942884	\N	utter_greet	{"event": "action", "timestamp": 1745081244.9942884, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "utter_greet", "policy": "TEDPolicy", "confidence": 0.9581753611564636, "action_text": null, "hide_rule_turn": false}
425	4	bot	1745081244.9942884	\N	\N	{"event": "bot", "timestamp": 1745081244.9942884, "metadata": {"utter_action": "utter_greet", "model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Hello! I'm your AI customer support assistant. How can I help you today?", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
426	4	action	1745081245.0022972	\N	action_listen	{"event": "action", "timestamp": 1745081245.0022972, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.45852577686309814, "action_text": null, "hide_rule_turn": false}
427	4	user	1745081278.4036677	ask_order_status	\N	{"event": "user", "timestamp": 1745081278.4036677, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Order #ORD-61833 need to know the status", "parse_data": {"intent": {"name": "ask_order_status", "confidence": 0.9992722868919373}, "entities": [{"entity": "order_number", "start": 6, "end": 7, "confidence_entity": 0.9664782881736755, "value": "#", "extractor": "DIETClassifier"}, {"entity": "order_number", "start": 7, "end": 16, "confidence_entity": 0.992752194404602, "value": "ORD-61833", "extractor": "DIETClassifier"}], "text": "Order #ORD-61833 need to know the status", "message_id": "0e98d50d526544aa896512135382604b", "metadata": {}, "text_tokens": [[0, 5], [6, 7], [7, 16], [17, 21], [22, 24], [25, 29], [30, 33], [34, 40]], "intent_ranking": [{"name": "ask_order_status", "confidence": 0.9992722868919373}, {"name": "greet", "confidence": 0.0002620659943204373}, {"name": "ask_reset_password", "confidence": 0.00020178135309834033}, {"name": "provide_email", "confidence": 9.318826050730422e-05}, {"name": "out_of_scope", "confidence": 7.66966913943179e-05}, {"name": "ask_create_account", "confidence": 2.285129448864609e-05}, {"name": "request_cancel_order", "confidence": 2.1079766156617552e-05}, {"name": "ask_order_cancel", "confidence": 8.264564712590072e-06}, {"name": "ask_payment_methods", "confidence": 8.013858860067558e-06}, {"name": "goodbye", "confidence": 6.578900865861215e-06}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "0e98d50d526544aa896512135382604b"}
428	4	slot	1745081278.4036677	\N	order_number	{"event": "slot", "timestamp": 1745081278.4036677, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
429	4	user_featurization	1745081282.6114361	\N	\N	{"event": "user_featurization", "timestamp": 1745081282.6114361, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
430	4	action	1745081282.6114361	\N	action_check_order_status	{"event": "action", "timestamp": 1745081282.6114361, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_check_order_status", "policy": "TEDPolicy", "confidence": 0.991733193397522, "action_text": null, "hide_rule_turn": false}
431	4	bot	1745081282.6114361	\N	\N	{"event": "bot", "timestamp": 1745081282.6114361, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Your order ORD-61833 is being processed. Estimated delivery: March 19, 2025.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
432	4	slot	1745081282.6114361	\N	order_number	{"event": "slot", "timestamp": 1745081282.6114361, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
433	4	action	1745081282.6194634	\N	action_listen	{"event": "action", "timestamp": 1745081282.6194634, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999244213104248, "action_text": null, "hide_rule_turn": false}
434	4	user	1745081307.826152	ask_order_items	\N	{"event": "user", "timestamp": 1745081307.826152, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "can you list out items in the Order #ORD-61833", "parse_data": {"intent": {"name": "ask_order_items", "confidence": 0.9971764087677002}, "entities": [{"entity": "order_number", "start": 36, "end": 37, "confidence_entity": 0.9673561453819275, "value": "#", "extractor": "DIETClassifier"}, {"entity": "order_number", "start": 37, "end": 46, "confidence_entity": 0.9899349808692932, "value": "ORD-61833", "extractor": "DIETClassifier"}], "text": "can you list out items in the Order #ORD-61833", "message_id": "4eab238a90604c7c8cbee890b7876353", "metadata": {}, "text_tokens": [[0, 3], [4, 7], [8, 12], [13, 16], [17, 22], [23, 25], [26, 29], [30, 35], [36, 37], [37, 46]], "intent_ranking": [{"name": "ask_order_items", "confidence": 0.9971764087677002}, {"name": "thank", "confidence": 0.0005524299340322614}, {"name": "out_of_scope", "confidence": 0.0004731591616291553}, {"name": "ask_shipping_time", "confidence": 0.00032549555180594325}, {"name": "goodbye", "confidence": 0.00028339261189103127}, {"name": "deny", "confidence": 0.0002612752723507583}, {"name": "ask_return_policy", "confidence": 0.00022351085499394685}, {"name": "provide_email", "confidence": 0.00012486227205954492}, {"name": "confirm_cancel_order", "confidence": 0.00010801271855598316}, {"name": "ask_order_status", "confidence": 0.00010605000716168433}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "4eab238a90604c7c8cbee890b7876353"}
435	4	slot	1745081307.826152	\N	order_number	{"event": "slot", "timestamp": 1745081307.826152, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
436	4	user_featurization	1745081307.8503892	\N	\N	{"event": "user_featurization", "timestamp": 1745081307.8503892, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
437	4	action	1745081307.8503892	\N	action_unlikely_intent	{"event": "action", "timestamp": 1745081307.8503892, "metadata": {"query_intent": {"name": "ask_order_items", "score": -0.4786053001880646, "threshold": -0.22928979992866516, "severity": 0.24931550025939941}, "ranking": [{"name": "ask_track_order", "score": 0.16097545623779297, "threshold": -0.1185281053185463, "severity": -0.27950355410575867}, {"name": "request_cancel_order", "score": 0.07577545195817947, "threshold": -0.3135973811149597, "severity": -0.3893728256225586}, {"name": "ask_reset_password", "score": -0.06375880539417267, "threshold": -0.39262011647224426, "severity": -0.3288612961769104}, {"name": "thank", "score": -0.06377911567687988, "threshold": -0.5919429063796997, "severity": -0.5281637907028198}, {"name": "ask_order_status", "score": -0.16669823229312897, "threshold": -0.2150673270225525, "severity": -0.04836909472942352}, {"name": "goodbye", "score": -0.3079308867454529, "threshold": -0.3301572799682617, "severity": -0.022226393222808838}, {"name": "ask_order_items", "score": -0.4786053001880646, "threshold": -0.22928979992866516, "severity": 0.24931550025939941}, {"name": "greet", "score": -0.6540244221687317, "threshold": -0.3261033892631531, "severity": 0.3279210329055786}, {"name": "ask_shipping_time", "score": -0.6692357063293457, "threshold": -0.4909745752811432, "severity": 0.17826113104820251}, {"name": "ask_order_cancel", "score": -0.774948000907898, "threshold": -0.536137044429779, "severity": 0.2388109564781189}], "model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_unlikely_intent", "policy": "UnexpecTEDIntentPolicy", "confidence": 1.0, "action_text": null, "hide_rule_turn": false}
438	4	action	1745081311.999271	\N	action_list_order_items	{"event": "action", "timestamp": 1745081311.999271, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_list_order_items", "policy": "TEDPolicy", "confidence": 0.992088794708252, "action_text": null, "hide_rule_turn": false}
439	4	bot	1745081311.999271	\N	\N	{"event": "bot", "timestamp": 1745081311.999271, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Here are the items in your order ORD-61833:\\n\\n1. Gaming Console - Quantity: 3, Price: $393.13, Total: $1179.39\\n2. 4K Monitor - Quantity: 2, Price: $656.81, Total: $1313.62\\n3. Wireless Headphones - Quantity: 2, Price: $104.88, Total: $209.76\\n\\nTotal order amount: $2702.77\\nOrder status: processing", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
440	4	bot	1745081311.999271	\N	\N	{"event": "bot", "timestamp": 1745081311.999271, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Would you like to cancel this order? You can say 'cancel this order' if you want to.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
441	4	slot	1745081311.999271	\N	order_number	{"event": "slot", "timestamp": 1745081311.999271, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
442	4	action	1745081312.015807	\N	action_listen	{"event": "action", "timestamp": 1745081312.015807, "metadata": {"model_id": "8fd152aa48c34ad3858442831bcdc0dc", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9998962879180908, "action_text": null, "hide_rule_turn": false}
456	4	bot	1745082444.766837	\N	\N	{"event": "bot", "timestamp": 1745082444.766837, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Would you like to cancel this order? You can say 'cancel this order' if you want to.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
457	4	slot	1745082444.766837	\N	order_number	{"event": "slot", "timestamp": 1745082444.766837, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
458	4	action	1745082444.782479	\N	action_listen	{"event": "action", "timestamp": 1745082444.782479, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999021291732788, "action_text": null, "hide_rule_turn": false}
443	4	user	1745082091.8317597	ask_order_items	\N	{"event": "user", "timestamp": 1745082091.8317597, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "can you list out items in the Order #ORD-61833", "parse_data": {"intent": {"name": "ask_order_items", "confidence": 0.9971764087677002}, "entities": [{"entity": "order_number", "start": 36, "end": 37, "confidence_entity": 0.9673561453819275, "value": "#", "extractor": "DIETClassifier"}, {"entity": "order_number", "start": 37, "end": 46, "confidence_entity": 0.9899349808692932, "value": "ORD-61833", "extractor": "DIETClassifier"}], "text": "can you list out items in the Order #ORD-61833", "message_id": "14a6931c180a43d59b10e9252e038127", "metadata": {}, "text_tokens": [[0, 3], [4, 7], [8, 12], [13, 16], [17, 22], [23, 25], [26, 29], [30, 35], [36, 37], [37, 46]], "intent_ranking": [{"name": "ask_order_items", "confidence": 0.9971764087677002}, {"name": "thank", "confidence": 0.0005524299340322614}, {"name": "out_of_scope", "confidence": 0.0004731591616291553}, {"name": "ask_shipping_time", "confidence": 0.00032549555180594325}, {"name": "goodbye", "confidence": 0.00028339261189103127}, {"name": "deny", "confidence": 0.0002612752723507583}, {"name": "ask_return_policy", "confidence": 0.00022351085499394685}, {"name": "provide_email", "confidence": 0.00012486227205954492}, {"name": "confirm_cancel_order", "confidence": 0.00010801271855598316}, {"name": "ask_order_status", "confidence": 0.00010605000716168433}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "14a6931c180a43d59b10e9252e038127"}
444	4	slot	1745082091.8317597	\N	order_number	{"event": "slot", "timestamp": 1745082091.8317597, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
445	4	user_featurization	1745082097.2825587	\N	\N	{"event": "user_featurization", "timestamp": 1745082097.2825587, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
446	4	action	1745082097.2825587	\N	action_list_order_items	{"event": "action", "timestamp": 1745082097.2825587, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_list_order_items", "policy": "TEDPolicy", "confidence": 0.9902438521385193, "action_text": null, "hide_rule_turn": false}
447	4	bot	1745082097.2825587	\N	\N	{"event": "bot", "timestamp": 1745082097.2825587, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Here are the items in your order ORD-61833:\\n\\n1. Gaming Console - Quantity: 3, Price: $393.13, Total: $1179.39\\n2. 4K Monitor - Quantity: 2, Price: $656.81, Total: $1313.62\\n3. Wireless Headphones - Quantity: 2, Price: $104.88, Total: $209.76\\n\\nTotal order amount: $2702.77\\nOrder status: processing", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
448	4	bot	1745082097.2825587	\N	\N	{"event": "bot", "timestamp": 1745082097.2825587, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Would you like to cancel this order? You can say 'cancel this order' if you want to.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
449	4	slot	1745082097.2825587	\N	order_number	{"event": "slot", "timestamp": 1745082097.2825587, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
450	4	action	1745082097.299287	\N	action_listen	{"event": "action", "timestamp": 1745082097.299287, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999057054519653, "action_text": null, "hide_rule_turn": false}
451	4	user	1745082440.6115491	ask_order_items	\N	{"event": "user", "timestamp": 1745082440.6115491, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "can you list out items in the Order #ORD-61833", "parse_data": {"intent": {"name": "ask_order_items", "confidence": 0.9971764087677002}, "entities": [{"entity": "order_number", "start": 36, "end": 37, "confidence_entity": 0.9673561453819275, "value": "#", "extractor": "DIETClassifier"}, {"entity": "order_number", "start": 37, "end": 46, "confidence_entity": 0.9899349808692932, "value": "ORD-61833", "extractor": "DIETClassifier"}], "text": "can you list out items in the Order #ORD-61833", "message_id": "c987befa4c864dfaaa88da89ab7a42ab", "metadata": {}, "text_tokens": [[0, 3], [4, 7], [8, 12], [13, 16], [17, 22], [23, 25], [26, 29], [30, 35], [36, 37], [37, 46]], "intent_ranking": [{"name": "ask_order_items", "confidence": 0.9971764087677002}, {"name": "thank", "confidence": 0.0005524299340322614}, {"name": "out_of_scope", "confidence": 0.0004731591616291553}, {"name": "ask_shipping_time", "confidence": 0.00032549555180594325}, {"name": "goodbye", "confidence": 0.00028339261189103127}, {"name": "deny", "confidence": 0.0002612752723507583}, {"name": "ask_return_policy", "confidence": 0.00022351085499394685}, {"name": "provide_email", "confidence": 0.00012486227205954492}, {"name": "confirm_cancel_order", "confidence": 0.00010801271855598316}, {"name": "ask_order_status", "confidence": 0.00010605000716168433}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "c987befa4c864dfaaa88da89ab7a42ab"}
452	4	slot	1745082440.6115491	\N	order_number	{"event": "slot", "timestamp": 1745082440.6115491, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
453	4	user_featurization	1745082444.766837	\N	\N	{"event": "user_featurization", "timestamp": 1745082444.766837, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
454	4	action	1745082444.766837	\N	action_list_order_items	{"event": "action", "timestamp": 1745082444.766837, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_list_order_items", "policy": "TEDPolicy", "confidence": 0.987642765045166, "action_text": null, "hide_rule_turn": false}
455	4	bot	1745082444.766837	\N	\N	{"event": "bot", "timestamp": 1745082444.766837, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Here are the items in your order ORD-61833:\\n\\n1. Gaming Console - Quantity: 3, Price: $393.13, Total: $1179.39\\n2. 4K Monitor - Quantity: 2, Price: $656.81, Total: $1313.62\\n3. Wireless Headphones - Quantity: 2, Price: $104.88, Total: $209.76\\n\\nTotal order amount: $2702.77\\nOrder status: processing", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
459	4	user	1745082568.061691	ask_order_items	\N	{"event": "user", "timestamp": 1745082568.061691, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "can you list out items in the Order #ORD-61833", "parse_data": {"intent": {"name": "ask_order_items", "confidence": 0.9971764087677002}, "entities": [{"entity": "order_number", "start": 36, "end": 37, "confidence_entity": 0.9673561453819275, "value": "#", "extractor": "DIETClassifier"}, {"entity": "order_number", "start": 37, "end": 46, "confidence_entity": 0.9899349808692932, "value": "ORD-61833", "extractor": "DIETClassifier"}], "text": "can you list out items in the Order #ORD-61833", "message_id": "cc738d8c4a584a648b4b5f0d48fcb5f8", "metadata": {}, "text_tokens": [[0, 3], [4, 7], [8, 12], [13, 16], [17, 22], [23, 25], [26, 29], [30, 35], [36, 37], [37, 46]], "intent_ranking": [{"name": "ask_order_items", "confidence": 0.9971764087677002}, {"name": "thank", "confidence": 0.0005524299340322614}, {"name": "out_of_scope", "confidence": 0.0004731591616291553}, {"name": "ask_shipping_time", "confidence": 0.00032549555180594325}, {"name": "goodbye", "confidence": 0.00028339261189103127}, {"name": "deny", "confidence": 0.0002612752723507583}, {"name": "ask_return_policy", "confidence": 0.00022351085499394685}, {"name": "provide_email", "confidence": 0.00012486227205954492}, {"name": "confirm_cancel_order", "confidence": 0.00010801271855598316}, {"name": "ask_order_status", "confidence": 0.00010605000716168433}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "cc738d8c4a584a648b4b5f0d48fcb5f8"}
460	4	slot	1745082568.061691	\N	order_number	{"event": "slot", "timestamp": 1745082568.061691, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
461	4	user_featurization	1745082572.230627	\N	\N	{"event": "user_featurization", "timestamp": 1745082572.230627, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
462	4	action	1745082572.230627	\N	action_list_order_items	{"event": "action", "timestamp": 1745082572.230627, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_list_order_items", "policy": "TEDPolicy", "confidence": 0.987642765045166, "action_text": null, "hide_rule_turn": false}
463	4	bot	1745082572.230627	\N	\N	{"event": "bot", "timestamp": 1745082572.230627, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Here are the items in your order ORD-61833:\\n\\n1. Gaming Console - Quantity: 3, Price: $393.13, Total: $1179.39\\n2. 4K Monitor - Quantity: 2, Price: $656.81, Total: $1313.62\\n3. Wireless Headphones - Quantity: 2, Price: $104.88, Total: $209.76\\n\\nTotal order amount: $2702.77\\nOrder status: processing", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
464	4	bot	1745082572.230627	\N	\N	{"event": "bot", "timestamp": 1745082572.230627, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Would you like to cancel this order? You can say 'cancel this order' if you want to.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
465	4	slot	1745082572.230627	\N	order_number	{"event": "slot", "timestamp": 1745082572.230627, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
466	4	action	1745082572.2468967	\N	action_listen	{"event": "action", "timestamp": 1745082572.2468967, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999021291732788, "action_text": null, "hide_rule_turn": false}
467	4	user	1745083163.915356	ask_order_items	\N	{"event": "user", "timestamp": 1745083163.915356, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "can you list out items in the Order #ORD-61833", "parse_data": {"intent": {"name": "ask_order_items", "confidence": 0.9971764087677002}, "entities": [{"entity": "order_number", "start": 36, "end": 37, "confidence_entity": 0.9673561453819275, "value": "#", "extractor": "DIETClassifier"}, {"entity": "order_number", "start": 37, "end": 46, "confidence_entity": 0.9899349808692932, "value": "ORD-61833", "extractor": "DIETClassifier"}], "text": "can you list out items in the Order #ORD-61833", "message_id": "5b469e45b80445bdaed1d9896d861746", "metadata": {}, "text_tokens": [[0, 3], [4, 7], [8, 12], [13, 16], [17, 22], [23, 25], [26, 29], [30, 35], [36, 37], [37, 46]], "intent_ranking": [{"name": "ask_order_items", "confidence": 0.9971764087677002}, {"name": "thank", "confidence": 0.0005524299340322614}, {"name": "out_of_scope", "confidence": 0.0004731591616291553}, {"name": "ask_shipping_time", "confidence": 0.00032549555180594325}, {"name": "goodbye", "confidence": 0.00028339261189103127}, {"name": "deny", "confidence": 0.0002612752723507583}, {"name": "ask_return_policy", "confidence": 0.00022351085499394685}, {"name": "provide_email", "confidence": 0.00012486227205954492}, {"name": "confirm_cancel_order", "confidence": 0.00010801271855598316}, {"name": "ask_order_status", "confidence": 0.00010605000716168433}], "response_selector": {"all_retrieval_intents": [], "default": {"response": {"responses": null, "confidence": 0.0, "intent_response_key": null, "utter_action": "utter_None"}, "ranking": []}}}, "input_channel": "rest", "message_id": "5b469e45b80445bdaed1d9896d861746"}
468	4	slot	1745083163.9233527	\N	order_number	{"event": "slot", "timestamp": 1745083163.9233527, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
469	4	user_featurization	1745083167.1471646	\N	\N	{"event": "user_featurization", "timestamp": 1745083167.1471646, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "use_text_for_featurization": false}
470	4	action	1745083167.1471646	\N	action_list_order_items	{"event": "action", "timestamp": 1745083167.1471646, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_list_order_items", "policy": "TEDPolicy", "confidence": 0.987642765045166, "action_text": null, "hide_rule_turn": false}
471	4	bot	1745083167.1471646	\N	\N	{"event": "bot", "timestamp": 1745083167.1471646, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Here are the items in your order ORD-61833:\\n\\n1. Premium Wireless Headphones - Quantity: 1, Price: $89.99, Total: $89.99\\n2. Phone Charging Cable (2-pack) - Quantity: 2, Price: $12.99, Total: $25.98\\n3. Protective Phone Case - Quantity: 1, Price: $24.99, Total: $24.99\\n4. Screen Protector - Quantity: 1, Price: $15.98, Total: $15.98\\n5. Smart Watch - Quantity: 1, Price: $93.01, Total: $93.01\\n\\nTotal order amount: $249.95\\nOrder status: processing", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
472	4	bot	1745083167.1471646	\N	\N	{"event": "bot", "timestamp": 1745083167.1471646, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "text": "Would you like to cancel this order? You can say 'cancel this order' if you want to.", "data": {"elements": null, "quick_replies": null, "buttons": null, "attachment": null, "image": null, "custom": null}}
473	4	slot	1745083167.1471646	\N	order_number	{"event": "slot", "timestamp": 1745083167.1471646, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "order_number", "value": "ORD-61833"}
474	4	action	1745083167.1634057	\N	action_listen	{"event": "action", "timestamp": 1745083167.1634057, "metadata": {"model_id": "ec0d37a2f5174f20817a22598184db1f", "assistant_id": "20250419-114442-horizontal-account"}, "name": "action_listen", "policy": "TEDPolicy", "confidence": 0.9999021291732788, "action_text": null, "hide_rule_turn": false}
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, conversation_id, is_user, content, "timestamp") FROM stdin;
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, product_name, quantity, price) FROM stdin;
177	89	Laptop Sleeve	3	34.99
178	89	Smart Speaker	2	89.99
179	89	Tablet Stand	1	19.99
180	90	Smartphone Case	2	24.99
181	90	Laptop Sleeve	3	34.99
182	91	Bluetooth Keyboard	2	59.99
183	92	Wireless Headphones	3	129.99
184	93	Screen Protector	1	9.99
185	93	Smartphone Case	1	24.99
186	94	Bluetooth Keyboard	1	59.99
187	94	Tablet Stand	1	19.99
188	94	Wireless Charger	2	29.99
189	94	Wireless Headphones	2	129.99
190	95	USB-C Cable	3	12.99
191	95	Wireless Headphones	3	129.99
192	95	Wireless Charger	3	29.99
193	95	Smartphone Case	3	24.99
194	96	Laptop Sleeve	2	34.99
195	97	Bluetooth Keyboard	2	59.99
196	97	Wireless Headphones	2	129.99
197	97	Smartphone Case	3	24.99
198	98	USB-C Cable	3	12.99
199	99	Screen Protector	2	9.99
200	99	Tablet Stand	1	19.99
201	99	Wireless Charger	1	29.99
202	100	Smart Speaker	3	89.99
203	101	Smartphone Case	1	24.99
204	101	Wireless Headphones	2	129.99
205	101	Smart Speaker	1	89.99
206	101	Wireless Charger	1	29.99
207	102	Laptop Sleeve	3	34.99
208	102	USB-C Cable	1	12.99
209	102	Tablet Stand	2	19.99
210	102	Smartphone Case	1	24.99
211	102	Wireless Charger	2	29.99
212	103	Smartphone Case	2	24.99
213	103	Smart Speaker	3	89.99
214	103	Wireless Charger	3	29.99
215	103	Tablet Stand	2	19.99
216	103	Laptop Sleeve	3	34.99
217	104	Bluetooth Keyboard	2	59.99
218	104	Wireless Headphones	3	129.99
219	105	Power Bank	1	39.99
220	105	Smartphone Case	2	24.99
221	105	Tablet Stand	3	19.99
222	106	Wireless Headphones	1	129.99
223	106	Tablet Stand	3	19.99
224	106	Smartphone Case	1	24.99
225	107	Wireless Charger	1	29.99
226	107	Bluetooth Keyboard	2	59.99
227	107	Screen Protector	2	9.99
228	107	Laptop Sleeve	1	34.99
229	107	Power Bank	2	39.99
230	108	Wireless Charger	2	29.99
231	108	Power Bank	2	39.99
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, order_number, user_id, total_amount, status, ordered_at, estimated_delivery, delivered_at, shipping_address, tracking_number) FROM stdin;
89	ORD-35829	1	324.95	DELIVERED	2025-04-04 09:39:29.82134	2025-04-10 09:39:29.82134	2025-04-09 22:39:29.82134	624 Kamaraj Avenue, Coimbatore, Chennai, Tamil Nadu, India - 600078	TRK4916705
90	ORD-44768	1	179.94	BACKORDERED	2025-04-12 00:49:03.82134	2025-04-16 00:49:03.82134	\N	903 Anna Salai, Thanjavur, Tirunelveli, Tamil Nadu, India - 641001	TRK5858452
91	ORD-96480	1	179.97	SHIPPED	2025-03-29 09:34:29.82134	2025-04-06 09:34:29.82134	\N	452 Kamaraj Avenue, Tiruchirappalli, Madurai, Tamil Nadu, India - 600018	TRK4107901
92	ORD-72293	1	389.97	PROCESSING	2025-04-10 20:57:06.82134	2025-04-18 20:57:06.82134	\N	669 Nehru Street, Salem, Tirunelveli, Tamil Nadu, India - 600095	TRK1993268
93	ORD-67592	1	59.97	SHIPPED	2025-03-29 06:32:17.82134	2025-04-01 06:32:17.82134	\N	228 Nehru Street, Chennai, Madurai, Tamil Nadu, India - 620001	TRK9007289
94	ORD-55626	2	589.9200000000001	SHIPPED	2025-03-27 19:22:17.82134	2025-04-02 19:22:17.82134	\N	811 Gandhi Road, Salem, Madurai, Tamil Nadu, India - 600001	TRK2486804
95	ORD-16656	2	425.9100000000001	PENDING	2025-04-06 16:09:23.82134	2025-04-11 16:09:23.82134	\N	170 Nehru Street, Tirunelveli, Coimbatore, Tamil Nadu, India - 600018	\N
96	ORD-10638	2	69.98	SHIPPED	2025-04-09 19:30:07.82134	2025-04-16 19:30:07.82134	\N	374 Gandhi Road, Madurai, Chennai, Tamil Nadu, India - 600020	TRK4520339
97	ORD-69429	2	214.97000000000003	SHIPPED	2025-03-23 05:58:38.82134	2025-03-26 05:58:38.82134	\N	777 Kamaraj Avenue, Chennai, Tirunelveli, Tamil Nadu, India - 600095	TRK3472773
98	ORD-93048	2	12.99	PROCESSING	2025-04-06 11:34:34.82134	2025-04-16 11:34:34.82134	\N	572 Bharathiar Street, Madurai, Salem, Tamil Nadu, India - 600002	TRK3615455
99	ORD-56536	5	119.92999999999999	DELIVERED	2025-04-01 19:57:38.82134	2025-04-11 19:57:38.82134	2025-04-10 19:57:38.82134	239 Kamaraj Avenue, Coimbatore, Tiruchirappalli, Tamil Nadu, India - 641001	TRK3661620
100	ORD-87310	5	269.96999999999997	PROCESSING	2025-04-20 19:45:43.82134	2025-04-25 19:45:43.82134	\N	473 Kamaraj Avenue, Chennai, Tiruchirappalli, Tamil Nadu, India - 620001	TRK9367301
101	ORD-54526	5	739.9100000000001	PENDING	2025-03-29 11:20:34.82134	2025-04-02 11:20:34.82134	\N	394 Anna Salai, Coimbatore, Chennai, Tamil Nadu, India - 600003	\N
102	ORD-83639	5	215.91	DELIVERED	2025-03-26 14:55:03.82134	2025-04-04 14:55:03.82134	2025-04-02 23:55:03.82134	810 Gandhi Road, Vellore, Madurai, Tamil Nadu, India - 600095	TRK5564092
103	ORD-73081	5	404.90000000000003	BACKORDERED	2025-04-16 21:05:18.82134	2025-04-26 21:05:18.82134	\N	447 Anna Salai, Coimbatore, Madurai, Tamil Nadu, India - 600040	TRK5427467
104	ORD-84012	4	309.96000000000004	DELIVERED	2025-03-29 23:54:05.82134	2025-04-01 23:54:05.82134	2025-04-01 17:54:05.82134	515 Gandhi Road, Madurai, Salem, Tamil Nadu, India - 600001	TRK9389033
105	ORD-12410	4	209.92999999999998	SHIPPED	2025-04-02 19:45:48.82134	2025-04-10 19:45:48.82134	\N	990 Nehru Street, Thanjavur, Vellore, Tamil Nadu, India - 600002	TRK4504390
106	ORD-10427	4	354.94000000000005	SHIPPED	2025-04-04 19:45:20.82134	2025-04-08 19:45:20.82134	\N	129 Kamaraj Avenue, Vellore, Salem, Tamil Nadu, India - 641001	TRK9283083
107	ORD-74322	4	414.88	PROCESSING	2025-04-18 23:26:21.82134	2025-04-26 23:26:21.82134	\N	871 Bharathiar Street, Tirunelveli, Salem, Tamil Nadu, India - 600078	TRK3691467
108	ORD-71538	4	99.97	PROCESSING	2025-04-14 11:50:20.82134	2025-04-17 11:50:20.82134	\N	118 Anna Salai, Chennai, Tiruchirappalli, Tamil Nadu, India - 600095	TRK9580056
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, company_id, name, description, price, stock_quantity, image_url, category, created_at, updated_at) FROM stdin;
42	1	Dettol Liquid Handwash	Antibacterial liquid handwash with a refreshing fragrance, 200ml.	99	150	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcThRk051Q2bpnv2R5MqLW1EDOb2J9AHiM9FFQ&s	Personal Care	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
43	1	Harpic Toilet Bowl Cleaner	Powerful toilet cleaner with stain removal, 500ml.	150	200	https://m.media-amazon.com/images/I/51EDOZgkplL.jpg	Cleaning	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
44	1	Vim Dishwashing Gel	Lemon-scented dishwashing gel for tough grease, 500ml.	120	300	https://m.media-amazon.com/images/I/51A8+b9ZgHL.jpg	Kitchen Essentials	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
45	1	Scotch-Brite Sponge	Durable scrub sponge for dishwashing, pack of 3.	75	250	https://m.media-amazon.com/images/I/712IgUo8fjL.jpg	Kitchen Essentials	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
46	1	Lizol Floor Cleaner	Citrus-scented floor cleaner, 1L.	200	180	https://m.media-amazon.com/images/I/61W8NHxqS8L.jpg	Cleaning	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
47	1	Colgate Toothpaste	Cavity protection toothpaste, 200g.	110	400	https://m.media-amazon.com/images/I/61f+32QXZML.jpg	Personal Care	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
48	1	Philips LED Bulb	9W cool daylight LED bulb, energy-efficient.	150	100	https://m.media-amazon.com/images/I/51xKon1plxL._AC_UF894,1000_QL80_.jpg	Home Essentials	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
49	1	Ariel Detergent Powder	Top-load detergent powder for stain removal, 1kg.	250	220	https://m.media-amazon.com/images/I/71bgo79OXLL._AC_UF1000,1000_QL80_.jpg	Cleaning	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
50	1	Pigeon Gas Lighter	Stainless steel kitchen gas lighter with long nozzle.	80	350	https://www.bigbasket.com/media/uploads/p/xxl/40249614-2_2-pigeon-smart-gas-lighter-10009-stainless-steel-body-easy-to-use.jpg	Kitchen Essentials	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
52	1	Surf Excel Liquid	Liquid detergent for front-load machines, 1L.	220	160	https://m.media-amazon.com/images/I/41yiOXzQugL._AC_UF1000,1000_QL80_.jpg	Cleaning	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
53	1	Nivea Body Lotion	Moisturizing body lotion for dry skin, 400ml.	350	140	https://assets.ajio.com/medias/sys_master/root/20231220/sun1/6582d9b5ddf7791519dca409/-1117Wx1400H-4916003770-multi-MODEL.jpg	Personal Care	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
54	1	Good Knight Mosquito Repellent	Liquid vaporizer for mosquito protection, 45ml.	90	280	https://m.media-amazon.com/images/I/71H4nrOXz6L._AC_UF894,1000_QL80_.jpg	Home Essentials	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
55	1	Tissue Paper Roll	Soft and absorbent toilet paper, pack of 4 rolls.	180	500	https://m.media-amazon.com/images/I/61ZhKNfLiGL.jpg	Personal Care	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
56	1	Borosil Glass Set	Set of 6 drinking glasses, 350ml each.	400	80	https://m.media-amazon.com/images/I/61B1F2+EdhL.jpg	Kitchen Essentials	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
57	1	Eveready AA Batteries	Long-lasting AA batteries, pack of 10.	150	200	https://www.jiomart.com/images/product/original/491214005/eveready-red-1015-aa-carbon-zinc-batteries-pack-of-2-product-images-o491214005-p491214005-0-202205270018.jpg?im=Resize=(1000,1000)	Home Essentials	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
58	1	Pril Dishwashing Liquid	Krafty lime dishwashing liquid, 750ml.	160	240	https://www.bigbasket.com/media/uploads/p/xxl/40031951_11-pril-dishwash-liquid-active-2x-lime.jpg	Kitchen Essentials	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
59	1	Godrej Air Freshener	Floral-scented room freshener spray, 240ml.	140	190	https://i0.wp.com/wisycart.com/wp-content/uploads/2023/05/Sea-Breeze-01-jpg.webp	Home Essentials	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
61	1	Comfort Fabric Conditioner	After-wash fabric softener, 860ml.	200	170	https://m.media-amazon.com/images/I/61OKcvlJm9L.jpg	Cleaning	2025-04-21 12:03:13.675003	2025-04-21 12:03:13.675003
\.


--
-- Data for Name: support_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.support_data (id, company_id, question, answer, category, created_at, updated_at) FROM stdin;
1	1	How do I track my order?	You can track your order by logging into your account and viewing the 'Orders' section. Alternatively, you can use the tracking number sent to your email.	orders	2025-04-19 06:14:04.267985	2025-04-19 06:14:04.267985
2	1	What is your return policy?	Our return policy allows returns within 30 days of purchase. Items must be in original condition with tags attached. Please contact customer support to initiate a return.	returns	2025-04-19 06:14:04.269011	2025-04-19 06:14:04.269011
3	1	How long does shipping take?	Standard shipping typically takes 3-5 business days. Express shipping is available for 1-2 business day delivery.	shipping	2025-04-19 06:14:04.269011	2025-04-19 06:14:04.269011
4	1	Do you ship internationally?	Yes, we ship to most countries worldwide. International shipping typically takes 7-14 business days.	shipping	2025-04-19 06:14:04.269011	2025-04-19 06:14:04.269011
5	1	How can I change my password?	You can change your password by going to 'Account Settings' and selecting 'Change Password'.	account	2025-04-19 06:14:04.269011	2025-04-19 06:14:04.269011
6	1	What payment methods do you accept?	We accept all major credit cards, PayPal, and Apple Pay.	payment	2025-04-19 06:14:04.269011	2025-04-19 06:14:04.269011
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, email, password_hash, created_at, last_login, is_active) FROM stdin;
1	admin	admin@example.com	$2b$12$Gs.v2pv27cF3JhUeCyo2cuukSESxScdRy.F32tr1qkVz3N0bGjRSG	2025-04-19 06:14:04.26005	\N	t
2	testuser	test@example.com	$2b$12$Gs.v2pv27cF3JhUeCyo2cuukSESxScdRy.F32tr1qkVz3N0bGjRSG	2025-04-19 06:14:04.26005	\N	t
5	mohith	mohith@example.com	$2b$12$Gs.v2pv27cF3JhUeCyo2cuukSESxScdRy.F32tr1qkVz3N0bGjRSG	2025-04-19 14:53:06.907295	\N	t
4	padma	padma@example.com	$2b$12$Gs.v2pv27cF3JhUeCyo2cuukSESxScdRy.F32tr1qkVz3N0bGjRSG	2025-04-19 06:29:27.218989	2025-04-19 17:08:19.760414	t
\.


--
-- Name: cart_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cart_items_id_seq', 1, true);


--
-- Name: carts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.carts_id_seq', 2, true);


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.companies_id_seq', 1, true);


--
-- Name: conversations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.conversations_id_seq', 31, true);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.events_id_seq', 474, true);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 134, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 231, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 108, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_id_seq', 61, true);


--
-- Name: support_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.support_data_id_seq', 6, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (id);


--
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (id);


--
-- Name: carts carts_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_user_id_key UNIQUE (user_id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: conversations conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_order_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_order_number_key UNIQUE (order_number);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: support_data support_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_data
    ADD CONSTRAINT support_data_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: ix_events_sender_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_events_sender_id ON public.events USING btree (sender_id);


--
-- Name: cart_items cart_items_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.carts(id);


--
-- Name: cart_items cart_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: carts carts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: conversations conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.conversations
    ADD CONSTRAINT conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: messages messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.conversations(id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: products products_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: support_data support_data_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_data
    ADD CONSTRAINT support_data_company_id_fkey FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- PostgreSQL database dump complete
--

