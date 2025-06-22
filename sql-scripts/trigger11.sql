-- Listato 5.17

-- Definizione della funzione di aggiornamento
create or replace function gravidanza_controlla_ordinamento()
returns trigger language plpgsql as $$
declare
  rec record;
  is_init boolean := false;
  pre_rec record;
begin
  for rec in
    -- Selezione dei valori di parità per le gravidanze della  stessa paziente
    (select figli_nati_vivi as fnv, aborti_avuti as aa,
    figli_nati_pretermine as fnp, figli_nati_a_termine as fna,
    data_primo_ingresso
    from gravidanza
    where paziente_cf = new.paziente_cf
    order by data_primo_ingresso asc)
  loop
    -- Verifica dell'ordinamento
    if is_init
      and (rec.fnv < pre_rec.fnv
        or rec.aa < pre_rec.aa
        or rec.fnp < pre_rec.fnv
        or rec.fna < pre_rec.fna)
    then
      raise exception 'Almeno un attributo di parità non è ordinato';
    end if;
    is_init := true;
    pre_rec := rec;
  end loop;
end;
$$;
-- Definizione del trigger
create constraint trigger gravidanza_ordinamento
after insert or update on gravidanza
deferrable initially deferred
for each row
execute procedure gravidanza_controlla_ordinamento();