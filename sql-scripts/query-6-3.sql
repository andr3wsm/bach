-- Listato 6.3

-- Query principale
select s1.ep_operativi as episiotomie_operativi,
  s2.parti_operativi as parti_operativi,
  case when s2.parti_operativi = 0
    then 0
	  else s1.ep_operativi::numeric/s2.parti_operativi
  end as rapporto_episiotomie_operativi,
  s3.ep_vaginali as episiotomie_vaginali,
  s4.parti_vaginali as parti_vaginali,
  case when s4.parti_vaginali = 0
    then 0
	  else s3.ep_vaginali::numeric/s4.parti_vaginali
  end as rapporto_episiotomie_vaginali
from
-- Numero di tagli cesarei in travaglio spontaneo
(select count(*) as ep_operativi
from parto_con_travaglio
where lacerazioni = 'episiotomia'
  and sottotipo_parto = 'operativo') s1,
-- Numero di parti totali in travaglio spontaneo
(select count(*) as parti_operativi
from parto_con_travaglio
where sottotipo_parto = 'operativo') s2,
-- Numero di tagli cesarei in travaglio indotto
(select count(*) as ep_vaginali
from parto_con_travaglio
where lacerazioni = 'episiotomia'
  and sottotipo_parto = 'naturale') s3,
-- Numero di parti totali in travaglio indotto
(select count(*) as parti_vaginali
from parto_con_travaglio
where sottotipo_parto = 'naturale') s4;