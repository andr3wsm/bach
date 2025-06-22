-- Listato 5.x

-- Definizione della funzione di aggiornamento
create or replace function misurazione_neonato_controlla_vincoli()
returns trigger language plpgsql as $$
begin
  -- Presenza di almeno uno dei valori da misurare
  if
    old.valore_fcm is null
    and old.valore_toco is null
    and not exists (select * from misurazione_neonato
      where gravidanza_id = old.gravidanza_id
      and misurazione_istante = old.istante)
  then
    raise exception 'Nessun valore misurato per questo timestamp';
  end if;
  return old;
end;
$$;
-- Definizione del trigger
create constraint trigger misurazione_neonato_vincoli
after delete on misurazione_neonato
deferrable initially deferred
for each row
execute procedure misurazione_neonato_controlla_vincoli();