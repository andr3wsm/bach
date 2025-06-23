-- Listato 6.4

-- Definizione di una vista con il sottotipo di ogni parto
create view parto_sottotipo as
select
  gravidanza_id,
  robson,
  case when tipo_parto = 'cesareo_programmato'
    then 'cesareo'
    else sottotipo_parto
  end as sottotipo_parto
from parto natural left join parto_con_travaglio;
-- Query principale
select robson, parto_sottotipo as tipo, count(*) as numero_parti
from parto_sottotipo
where sottotipo_parto in ('cesareo','naturale')
group by robson, sottotipo_parto
order by robson, sottotipo_parto;