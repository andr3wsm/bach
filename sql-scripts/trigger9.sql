-- Listato 5.x

-- Definizione della funzione di aggiornamento
create or replace function misurazione_controlla_vincoli()
returns trigger language plpgsql as $$
begin
  -- Presenza di almeno uno dei valori da misurare
  if
    new.valore_fcm is null
    and new.valore_toco is null
    and not exists (select * from misurazione_neonato
      where gravidanza_id = new.gravidanza_id
      and misurazione_istante = new.istante)
  then
    raise exception 'Nessun valore misurato per questo timestamp';
  end if;
  return new;
end;
$$;
-- Definizione del trigger
create constraint trigger misurazione_vincoli
after insert or update on misurazione
deferrable initially deferred
for each row
execute procedure misurazione_controlla_vincoli();