-- Listato 5.23

-- Definizione della funzione di aggiornamento
create or replace function parto_controlla_tipo()
returns trigger language plpgsql as $$
begin
  -- Corrispondenza tra tipo_parto e tabelle
  if (new.tipo_parto = 'cesareo_programmato')
  then
    -- Si verifica che sia in cesareo programmato
    -- E non in parto con travaglio
    if
      exists (select count(*) from cesareo_programmato
        where gravidanza_id = new.gravidanza_id)
      and not exists (select count(*) from parto_con_cesareo
        where gravidanza_id = new.gravidanza_id)
    then return new;
    else raise exception 'Non corrisponde a cesareo_programmato';
    end if;
  else
    -- Si verifica che sia in parto con travaglio
    -- E non in cesareo programmato
    if
      exists (select count(*) from parto_con_travaglio
        where gravidanza_id = new.gravidanza_id)
      and not exists (select count(*) from cesareo_programmato
        where gravidanza_id = new.gravidanza_id)
    then return new;
    else raise exception 'Non corrisponde a parto_con_travaglio';
    end if;
  end if;
end;
$$;
-- Definizione del trigger
create constraint trigger parto_tipo
after insert or update on parto
deferrable initially deferred
for each row
execute procedure parto_controlla_tipo();