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
create domain stato_crescita enum as varchar
check (value in ('regolare','fgr','sga'));

-- Listato 5.x

create table paziente (
  cf codice_fiscale
  primary key (cf)
  nome varchar not null
  cognome varchar not null,
  data_nascita date not null
);

-- Listato 5.x

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
  pma_ovodonazione boolean
  pregresso_gdm boolean not null,
  pregressa_pih boolean not null,
  pregressa_tireopatia boolean not null,
  pregressa_preeclampsia boolean not null,
  data_prevista_parto date,
  ultima_mestruazione_ecografica date,
  ultima_mestruazione_anamnestica date,
  annotazioni text
);

-- Listato 5.x

alter table gravidanza
-- Vincolo di chiave esterna
add foreign key (paziente_cf)
references paziente.cf
on update cascade on delete cascade,
-- Vincolo sugli attributi relativi alla PMA
add constraint gravidanza_pma_vincolo
check ((pma_tipo is null and pma_ovodonazione is null)
  or (pma_tipo is not null and pma_ovodonazione is not null));

-- Listato 5.x

create table malattia (
  codice varchar,
  primary key (codice),
  nome varchar not null
);

-- Listato 5.x

create table malattia_gravidanza (
  gravidanza_id integer,
  malattia_codice varchar,
  primary key (gravidanza_id, malattia_codice),
  terapia text
);

-- Listato 5.x

alter table malattia_gravidanza
-- Vincolo di chiave esterna verso gravidanza
add foreign key (gravidanza_id)
references gravidanza.id
on update cascade on delete cascade,
-- Vincolo di chiave esterna verso malattia
add foreign key (malattia_codice)
references malattia.codice
on update cascade on delete cascade;

-- Listato 5.x

create table visita (
  gravidanza_id integer,
  data date,
  primary key (gravidanza_id, data)
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
  utpi float,
  altezza float,
  peso float,
  annotazioni text
);

-- Listato 5.x

alter table visita
add foreign key (gravidanza_id)
references gravidanza.id
on update cascade on delete cascade;