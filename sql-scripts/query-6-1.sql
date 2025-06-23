-- Listato 6.1

-- Definizione di una vista con il numero di induzioni per parto
create view parto_con_travaglio_induzione as
select *
from parto_con_travaglio p natural join
  (select count(*) as induzioni, gravidanza_id
  from induzione
  group by gravidanza_id);

-- Query principale
select s1.tc_travaglio_spontaneo as tc_travaglio_spontaneo,
  s2.parti_travaglio_spontaneo as parti_travaglio_spontaneo,
  case when s2.parti_travaglio_spontaneo = 0
    then 0
	  else s1.tc_travaglio_spontaneo/s2.parti_travaglio_spontaneo
  end as rapporto_tc_travaglio_spontaneo,
  s3.tc_travaglio_indotto as tc_travaglio_indotto,
  s4.parti_travaglio_indotto as parti_travaglio_indotto,
  case when s4.parti_travaglio_indotto = 0
    then 0
	  else s3.tc_travaglio_indotto/s4.parti_travaglio_indotto
  end as rapporto_tc_travaglio_indotto
from
-- Numero di tagli cesarei in travaglio spontaneo
(select count(*) as tc_travaglio_spontaneo
from parto_con_travaglio_induzione
where induzioni = 0
  and sottotipo_parto like '%cesareo%') s1,
-- Numero di parti totali in travaglio spontaneo
(select count(*) as parti_travaglio_spontaneo
from parto_con_travaglio_induzione
where induzioni = 0) s2,
-- Numero di tagli cesarei in travaglio indotto
(select count(*) as tc_travaglio_indotto
from parto_con_travaglio_induzione
where induzioni > 0
  and sottotipo_parto like '%cesareo') s3,
-- Numero di parti totali in travaglio indotto
(select count(*) as parti_travaglio_indotto
from parto_con_travaglio_induzione
where induzioni > 0) s4;