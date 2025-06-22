-- Listato 5.20

-- Definizione della funzione di aggiornamento
create or replace function visita_parto_controlla_vincoli()
returns trigger language plpgsql as $$
begin
  -- Presenza di una visita o di un parto
  if
    not exists (select gravidanza_id from visita
    where gravidanza_id = old.id
    union
    select gravidanza_id from parto
    where gravidanza_id = old.id)
  then
    raise exception 'La gravidanza non ha visite né parto associato';
  end if;
end;
$$;
-- Definizione del trigger per la tabella visita
create constraint trigger visita_vincoli
after delete on visita
deferrable initially deferred
for each row
execute procedure gravidanza_controlla_vincoli();
-- Definizione del trigger per la tabella parto
create constraint trigger parto_vincoli
after delete on parto
deferrable initially deferred
for each row
execute procedure gravidanza_controlla_vincoli();