-- Listato 5.24

-- Definizione della funzione di aggiornamento
create or replace function parto_controlla_tipo_2()
returns trigger language plpgsql as $$
begin
  -- Corrispondenza tra tipo_parto e tabelle
  if (old.tipo_parto = 'cesareo_programmato')
  then
    -- Si verifica che sia in cesareo programmato
    -- E non in parto con travaglio
    if
      exists (select count(*) from cesareo_programmato
        where gravidanza_id = old.gravidanza_id)
      and not exists (select count(*) from parto_con_cesareo
        where gravidanza_id = old.gravidanza_id)
    then return old;
    else raise exception 'Non corrisponde a cesareo_programmato';
    end if;
  else
    -- Si verifica che sia in parto con travaglio
    -- E non in cesareo programmato
    if
      exists (select count(*) from parto_con_travaglio
        where gravidanza_id = old.gravidanza_id)
      and not exists (select count(*) from cesareo_programmato
        where gravidanza_id = old.gravidanza_id)
    then return old;
    else raise exception 'Non corrisponde a parto_con_travaglio';
    end if;
  end if;
end;
$$;
-- Definizione del trigger
create constraint trigger cesareo_programmato_vincoli
after delete on cesareo_programmato
deferrable initially deferred
for each row
execute procedure parto_controlla_tipo_2();
-- Definizione del trigger
create constraint trigger parto_con_travaglio_vincoli
after delete on parto_con_travaglio
deferrable initially deferred
for each row
execute procedure parto_controlla_tipo_2();