-- Listato 5.19

-- Definizione della funzione di aggiornamento
create or replace function gravidanza_controlla_vincoli()
returns trigger language plpgsql as $$
begin
  -- Presenza di una visita o di un parto
  if
    not exists (select gravidanza_id from visita
    where gravidanza_id = new.id
    union
    select gravidanza_id from parto
    where gravidanza_id = new.id)
  then
    raise exception 'La gravidanza non ha visite né parto associato';
  end if;
  -- Presenza di non più di una visita del primo trimestre
  if
    ((select count(*) from visita
    where gravidanza_id = new.id
    and categoria_visita = 'primo_trimestre') > 1)
  then
    raise exception 'Più di una visita del primo trimestre';
  end if;
  -- Presenza di non più di una visita del secondo trimestre
  if
    ((select count(*) from visita
    where gravidanza_id = new.id
    and categoria_visita = 'secondo_trimestre') > 1)
  then
    raise exception 'Più di una visita del secondo trimestre';
  end if;
  return new;
end;
$$;
-- Definizione del trigger
create constraint trigger gravidanza_vincoli
after insert or update on gravidanza
deferrable initially deferred
for each row
execute procedure gravidanza_controlla_vincoli();