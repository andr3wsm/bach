-- Listato 5.21

-- Definizione della funzione di aggiornamento
create or replace function visita_calcola_eta()
returns trigger language plpgsql as $$
declare
  data_nascita date;
begin
  data_nascita :=
    (select data_nascita from persona, gravidanza
    where persona.cf = gravidanza.paziente_cf
    and gravidanza.id = new.gravidanza_id);
  new.eta := extract (year from age(new.data,data_nascita));
  return new;
end;
$$;
-- Definizione del trigger
create constraint trigger visita_eta
after insert or update on visita
deferrable initially deferred
for each row
execute procedure visita_calcola_eta();