-- Listato 5.18

-- Definizione della funzione di aggiornamento
create or replace function gravidanza_aggiorna_derivati()
returns trigger language plpgsql as $$
begin
  -- Calcolo dell'attributo parità
  new.parita := cast(new.figli_nati_a_termine as text)
    || cast(new.figli_nati_pretermine as text)
    || cast(new.aborti_avuti as text)
    || cast(new.figli_nati_vivi as text);
  -- Calcolo dell'attributo data_primo_ingresso
  new.data_primo_ingresso :=
    (select min(data) from
      (select data from visita
      where gravidanza_id = new.id
      union
      select data_parto from parto
      where gravidanza_id = new.id));
  return new;
end;
$$;
-- Definizione del trigger
create constraint trigger gravidanza_derivati
after insert or update on gravidanza
deferrable initially deferred
for each row
execute procedure gravidanza_aggiorna_derivati();