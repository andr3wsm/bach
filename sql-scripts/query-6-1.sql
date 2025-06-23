-- Listato 6.1

-- Query principale
select *
from
  (select gravidanza_id, peso/(altezza*altezza) as bmi
  from visita
  where categoria_visita = 'primo_trimestre'
    and altezza is not null
    and altezza <> 0
    and peso is not null)
  natural join
  (select gravidanza_id, lacerazioni
  from parto_con_travaglio);