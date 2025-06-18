-- Listato 5.19

-- Definizione della funzione di aggiornamento
create or replace function esame_controlla_esito()
returns trigger language plpgsql as $$
declare
  tipo_esito varchar[];
  esito_val varchar;
  numerico boolean := true;
begin
  tipo_esito := (select tipo_esito from esame
    where nome = new.esame_nome);
  -- Corrispondenza del tipo dell'esito
  if (tipo_esito[1] == 'numeric')
  then
    -- Caso numerico
    begin
      esito_val := new.esito::nuumeric;
    exception when others then
      numerico := false;
    end;
    if numerico
    then return new;
    else raise exception 'Non corrisponde al tipo numerico';
    end if;
  else
  if (tipo_esito[1] == 'string')
  then
    -- Caso stringa generica
    return new;
  else
    -- Caso tipo enum
    if (new.esito = any (tipo_esito))
    then return new;
    else raise exception 'Non corrisponde al tipo enumerazione';
    end if;
  end if;
  end if;
  return new;
end;
$$;
-- Definizione del trigger
create constraint trigger esame_esito
after insert or update on esame_visita
deferrable initially deferred
for each row
execute procedure esame_controlla_esito();