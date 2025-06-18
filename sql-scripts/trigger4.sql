create constraint trigger visita_vincoli
after delete on visita
deferrable initially deferred
for each row
execute procedure gravidanza_controlla_vincoli();