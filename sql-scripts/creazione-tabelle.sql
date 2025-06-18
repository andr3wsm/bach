-- Listato 5.1

-- Dominio codice_fiscale per persona
create domain codice_fiscale as char(16);
-- Dominio pma_tipo_enum per +gravidanza
create domain pma_tipo_enum as varchar
check (value in ('iui','fivet','icsi'));
-- Dominio categoria_visita_enum per visita
create domain categoria_visita_enum as varchar
check (value in ('primo_trimestre','secondo_trimestre','biometrica',
  'altro_tipo'));
-- Dominio stato_crescita_enum per visita
create domain stato_crescita_enum as varchar
check (value in ('regolare','fgr','sga'));
-- Dominio tipo_parto_enum per parto
create domain tipo_parto_enum as varchar
check (value in ('cesareo_programmato','parto_con_travaglio'));
-- Dominio tipo_secondamento_enum per parto
create domain tipo_secondamento_enum as varchar
check (value in ('attivo','strumentale','manuale','scovolamento'));
-- Dominio robson_enum per parto
create domain robson_enum as varchar
check (value in ('1','2a','2b','3','4a','4b','5.1','5.2',
  '6','7','8','9','10'));
-- Dominio analgesia_enum per parto
create domain analgesia_enum as varchar
check (value in ('spinale','peridurale','spinale_peridurale',
  'calinox'));
-- Dominio sottotipo_parto_enum per parto_con_travaglio
create domain sottotipo_parto_enum as varchar
check (value in ('naturale','operativo','cesareo','naturale_operativo',
  'naturale_cesareo','operativo_cesareo'));
-- Dominio lacerazioni_enum per parto_con_travaglio
create domain lacerazioni_enum as varchar
check (value in ('nessuna','episiotomia','tracheloraffia','grado_1',
  'grado_2','grado_3','grado_4','altro'));
-- Dominio metodo_induzione per induzione
create domain metodo_induzione as varchar
check (value in ('amnioressi','cook','cook_misoprostolo','cook_ossitocina',
  'dilapan','dilapan_misoprostolo','dilapan_ossitocina','misoprostolo',
  'propess','propidil'));

-- Listato 5.2

create table paziente (
  cf codice_fiscale,
  primary key (cf),
  nome varchar not null,
  cognome varchar not null,
  data_nascita date not null
);

-- Listato 5.3

create table gravidanza (
  id serial,
  primary key (id),
  paziente_cf codice_fiscale not null,
  data_primo_ingresso date not null,
  unique (paziente_cf, data_primo_ingresso),
  figli_nati_vivi integer not null,
  aborti_avuti integer not null,
  figli_nati_pretermine integer not null,
  figli_nati_a_termine integer not null,
  unique (paziente_cf, figli_nati_vivi, aborti_avuti, figli_nati_pretermine,
    figli_nati_a_termine),
  parita varchar not null,
  eta_concepimento integer,
  esito boolean,
  pma_tipo pma_tipo_enum,
  pma_ovodonazione boolean,
  pregresso_gdm boolean not null,
  pregressa_pih boolean not null,
  pregressa_tireopatia boolean not null,
  pregressa_preeclampsia boolean not null,
  data_prevista_parto date,
  ultima_mestruazione_ecografica date,
  ultima_mestruazione_anamnestica date,
  annotazioni text,
  -- Vincolo di chiave esterna verso paziente
  foreign key (paziente_cf)
    references paziente (cf)
    on update cascade on delete cascade,
  -- Vincolo sugli attributi relativi alla PMA
  check ((pma_tipo is null and pma_ovodonazione is null)
    or (pma_tipo is not null and pma_ovodonazione is not null))
);

-- Listato 5.4

create table malattia (
  codice varchar,
  primary key (codice),
  nome varchar not null
);

-- Listato 5.5

create table malattia_gravidanza (
  gravidanza_id integer,
  malattia_codice varchar,
  primary key (gravidanza_id, malattia_codice),
  terapia text,
  -- Vincolo di chiave esterna verso gravidanza
  foreign key (gravidanza_id)
    references gravidanza (id)
    on update cascade on delete cascade,
  -- Vincolo di chiave esterna verso malattia
  foreign key (malattia_codice)
    references malattia (codice)
    on update cascade on delete cascade
);

-- Listato 5.6

create table visita (
  gravidanza_id integer,
  data date,
  primary key (gravidanza_id, data),
  epoca_gestazionale integer not null,
  eta integer not null,
  categoria_visita categoria_visita_enum not null,
  pressione_arteriosa_materna integer,
  anomalie_morfologiche_fetali text,
  prescrizione_asa boolean,
  decorso text,
  fuma boolean,
  premorfologica_indicata boolean,
  stato_crescita stato_crescita_enum,
  utpi real,
  altezza real,
  peso real,
  annotazioni text,
  -- Vincolo di chiave esterna verso gravidanza
  foreign key (gravidanza_id)
    references gravidanza (id)
    on update cascade on delete cascade
);

-- Listato 5.7

create table esame (
  nome varchar,
  primary key (nome),
  tipo varchar[] not null
);

-- Listato 5.8

create table esame_visita (
  gravidanza_id integer,
  visita_data date,
  esame_nome varchar,
  primary key (gravidanza_id, visita_data, esame_nome),
  esito varchar not null,
  data_esame date not null,
  -- Vincolo di chiave esterna verso visita
  foreign key (gravidanza_id, visita_data)
    references visita (gravidanza_id, data)
    on update cascade on delete cascade,
  -- Vincolo di chiave esterna verso esame
  foreign key (esame_nome)
    references esame (nome)
    on update cascade on delete cascade
);

-- Listato 5.9

create table parto (
  gravidanza_id integer,
  primary key (gravidanza_id),
  tipo_parto tipo_parto_enum not null,
  data_parto date not null,
  eta integer not null,
  epoca_gestazionale integer not null,
  istante_secondamento timestamp not null,
  tipo_secondamento tipo_secondamento_enum not null,
  robson robson_enum not null,
  analgesia analgesia_enum,
  perdita_ematica integer,
  annotazioni text,
  -- Vincolo di chiave esterna verso gravidanza
  foreign key (gravidanza_id)
    references gravidanza (id)
    on update cascade on delete cascade
);

-- Listato 5.10

create table cesareo_programmato (
  gravidanza_id integer,
  primary key (gravidanza_id),
  motivo varchar not null,
  -- Vincolo di chiave esterna verso parto
  foreign key (gravidanza_id)
    references parto (gravidanza_id)
    on update cascade on delete cascade
);

-- Listato 5.11

create table parto_con_travaglio (
  gravidanza_id integer,
  primary key (gravidanza_id),
  sottotipo_parto sottotipo_parto_enum not null,
  motivo varchar,
  lacerazioni lacerazioni_enum not null,
  kristeller boolean,
  istante_rottura_membrane timestamp,
  istante_inizio_fase_attiva timestamp,
  istante_dilatazione_completa timestamp,
  istante_inizio_fase_espulsiva timestamp,
  istante_espulsione timestamp,
  -- Vincolo di chiave esterna verso parto
  foreign key (gravidanza_id)
    references parto (gravidanza_id)
    on update cascade on delete cascade,
  -- Vincolo sull'attributo motivo
  check ((sottotipo_parto = 'naturale' and motivo is null)
    or (sottotipo_parto <> 'naturale' and motivo is not null)),
  -- Vincolo sull'attributo kristeller
  check ((sottotipo_parto = 'cesareo' and kristeller is null)
    or (sottotipo_parto <> 'cesareo' and kristeller is not null))
);

-- Listato 5.12

create table induzione (
  gravidanza_id integer,
  istante timestamp,
  primary key (gravidanza_id,istante),
  motivo varchar not null,
  metodo metodo_induzione not null,
  bishop integer not null,
  quantita integer not null,
  cicli_eseguiti integer not null,
  completamento real check (completamento >= 0 and completamento <= 1),
  -- Vincolo di chiave esterna verso parto_con_travaglio
  foreign key (gravidanza_id)
    references parto_con_travaglio (gravidanza_id)
    on update cascade on delete cascade
);

-- Listato 5.13

create table neonato (
  gravidanza_id integer,
  istante_nascita timestamp,
  primary key (gravidanza_id, istante_nascita),
  peso real,
  altezza real,
  sesso char not null check (sesso in ('M','F')),
  circonferenza_cranica real,
  be real,
  ph real,
  tin boolean not null,
  -- Vincolo di chiave esterna verso parto
  foreign key (gravidanza_id)
    references parto (gravidanza_id)
    on update cascade on delete cascade
);

-- Listato 5.14

create table tracciato (
  gravidanza_id integer,
  primary key (gravidanza_id),
  numero_progressivo varchar not null,
  istante_inizio timestamp not null,
  -- Vincolo di chiave esterna verso parto
  foreign key (gravidanza_id)
    references parto (gravidanza_id)
    on update cascade on delete cascade
);

-- Listato 5.15

create table misurazione (
  gravidanza_id integer,
  istante timestamp,
  primary key (gravidanza_id, istante),
  valore_fcm integer,
  valore_toco integer,
  -- Vincolo di chiave esterna verso tracciato
  foreign key (gravidanza_id)
    references tracciato (gravidanza_id)
    on update cascade on delete cascade
);

-- Listato 5.16

create table misurazione_neonato (
  misurazione_istante timestamp,
  gravidanza_id integer,
  neonato_istante_nascita timestamp,
  primary key (misurazione_istante, gravidanza_id, neonato_istante_nascita),
  -- Vincolo di chiave esterna verso misurazione
  foreign key (gravidanza_id, misurazione_istante)
    references misurazione (gravidanza_id, istante)
    on update cascade on delete cascade,
  -- Vincolo di chiave esterna verso neonato
  foreign key (gravidanza_id, neonato_istante_nascita)
    references neonato (gravidanza_id, istante_nascita)
    on update cascade on delete cascade
);