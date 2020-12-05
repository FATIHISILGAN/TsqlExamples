/*
 sorgu1
*/
select ad +' ' +soyad as Ad_soyad from personel 
/*
 sorgu1
*/

/*
 sorgu2
*/
select lower( proje.proje_ad) from proje 

/*
 sorgu2
*/


/*
 sorgu3
*/
select distinct( personel.maas)  from personel

/*
 sorgu3
*/


/*
 sorgu4
*/
select  * from personel p full join cocuk c 
on  p.personel_no=c.personel_no  full join ilce i on i.il_no=c.dogu_yeri full join il ix on ix.il_no=i.il_no full join unvan un on un.unvan_no=p.unvan_no 
full join birim brm on brm.birim_no =p.birim_no full join gorevlendirme grvlndrm on grvlndrm.personel_no =p.personel_no full join proje proj on proj.proje_no=grvlndrm.proje_no
/*
 sorgu4
*/



/*sorgu5*/

select * from personel where baslama_tarihi Like '2002-05__%'

/*sorgu5*/



/*sorgu6*/

select ad+' '+soyad as AdSoyad, personel.maas from personel 
WHERE personel.ad in(select personel.ad 
from personel where personel.maas BETWEEN '2000' AND '3000')

/*sorgu6*/




/*sorgu7*/

SELECT personel.birim_no,COUNT(*) as sayisi from personel group by birim_no 

/*sorgu7*/




/*sorgu8*/

select birim.birim_ad, personel.ad,personel.soyad,proje.proje_ad
from birim
inner join personel
on birim.birim_no = personel.birim_no
inner join gorevlendirme
on gorevlendirme.personel_no = personel.personel_no
inner join proje
on proje.proje_no = gorevlendirme.proje_no where birim.birim_ad='�DAR�'

/*sorgu8*/




/*sorgu9*/
select personel.ad as �sim, personel.soyad as Soyisim, count(cocuk.personel_no) as [ka� �ocuklu]
from personel 
INNER JOIN cocuk on cocuk.personel_no = personel.personel_no 
group by personel.ad,personel.soyad,cocuk.personel_no having count(cocuk.personel_no)>1
/*sorgu9*/



/*sorgu10*/
select maas from personel where personel.maas =( select  max(personel.maas) from personel where maas<5200) 
/*sorgu10*/



/*sorgu11*/
select * from personel where personel.personel_no<=(select COUNT(personel_no)/2 from personel)
/*sorgu11*/


/*sorgu12*/
select birim.birim_ad, count(personel.birim_no)
from personel
INNER JOIN birim on birim.birim_no = personel.birim_no
group by birim.birim_ad
having count(personel.birim_no)<5
/*sorgu12*/



/*13*/
select ilce_ad,il.il_ad, count(personel.dogum_yeri) as �al��anToplam
from personel
INNER JOIN ilce on personel.dogum_yeri = ilce.ilce_no
inner join il on il.il_no = ilce.il_no
group by il_ad,ilce.ilce_ad
having count(personel.dogum_yeri)>3
/*13*/


/*14*/
create function fn_personel_deneyim(@sayi int)
returns varchar(40)
as
begin
declare @sonuc varchar(20)
declare @baslamay�l int

set @baslamay�l = (select CONVERT(int, (select year(personel.baslama_tarihi) from personel where personel.personel_no=@sayi)))


if ( 2020-@baslamay�l>=20)
set @sonuc='deneyimli'
if (2020- @baslamay�l<20)
set @sonuc='deneyimsiz'
return @sonuc

end

select(dbo.fn_personel_deneyim(15))

/*14*/



/*15*/
alter function fn_personel_prim_hesap(@sayi int)
returns varchar(40)
as
begin
declare @sonuc varchar(50)
declare @calismasaati int
declare @maas int
declare @prim int



set @calismasaati = (select CONVERT(int, (select(personel.calisma_saati) from personel where personel.personel_no=@sayi)))
set @maas = (select CONVERT(int, (select (personel.maas) from personel where personel.personel_no=@sayi)))
set @prim = (select CONVERT(int, (select (personel.prim) from personel where personel.personel_no=@sayi)))


if (@calismasaati>35)
set @sonuc='zaml� maa�:'+ str(@maas+(@prim+(@prim*0.50)))
if (@calismasaati<=35)
set @sonuc='zams�z maa�:'+ str(@maas+@prim)
return @sonuc

end

select(dbo.fn_personel_prim_hesap(15))
/*15*/


/*16*/

create function cocuktan_prim_hesap(@sayi int)
returns varchar(40)
as
begin
declare @sonuc varchar(50)
declare @calisma_zamani int
declare @maas_degeri int
declare @prim_degeri int
declare @cocuk_sayisi int
declare @cocuk_dogum_tarihi int
Set @calisma_zamani = (select convert(int,(SELECT calisma_saati from personel where personel_no = @sayi)))
set @maas_Degeri = (select convert(int,(SELECT maas from personel where personel_no = @sayi)))
set @prim_Degeri = (select convert(int,(SELECT prim from personel where personel_no = @sayi)))
set @cocuk_sayisi = (select count(*) from personel, cocuk where personel.personel_no = cocuk.personel_no
                            and personel.personel_no = @sayi)
set @cocuk_dogum_tarihi = (select Max(YEAR(CURRENT_TIMESTAMP)-YEAR(cocuk.dogum_tarihi)) as yas from personel, cocuk 
                            where personel.personel_no = cocuk.personel_no
                            and personel.personel_no = @sayi)

if (@calisma_zamani>=35 and @cocuk_sayisi>=2 and (@cocuk_dogum_tarihi >=5))
set @sonuc='zaml� maa�:'+ str(@maas_Degeri+(@prim_degeri+(@prim_Degeri*0.50)))
if (@calisma_zamani<35 and @cocuk_sayisi<2 and (@cocuk_dogum_tarihi <5))
set @sonuc='normal maa�:'+ str(@maas_Degeri+@prim_degeri)

return @sonuc
end

select dbo.cocuktan_prim_hesap(19)

/*16*/




/*17*/
create Function projeDetay(@sayi int)
Returns Table
As
Return
(

select DISTINCT ad,soyad, unvan_ad, proje_ad, proje.baslama_tarihi, planlanan_bitis_tarihi, birim_ad from personel, proje, gorevlendirme, birim, unvan 
where personel.unvan_no = unvan.unvan_no and 
personel.birim_no = birim.birim_no and 
gorevlendirme.proje_no = proje.proje_no and personel.personel_no = @sayi
)

select*from projeDetay(10)
/*17*/


/*18*/
alter function devam_eden_proje(@sayi int)
returns varchar(40)
as
begin
declare @sonuc varchar(100)
declare @is_durum int

set @is_durum = (select CONVERT(int, (select year(proje.planlanan_bitis_tarihi) from proje where proje.proje_no=@sayi)))

if (@is_durum>=2020)
set @sonuc='Devam Eden Projeler'
if (@is_durum<2020)
set @sonuc='Biten Projeler'
else 
set @sonuc = '1-5 aras�nda de�erler girin'

return @sonuc

end

select dbo.devam_eden_proje(1)
/*18*/






/*20*/
select personel.ad,personel.soyad,unvan.unvan_ad,proje_ad,proje.baslama_tarihi,planlanan_bitis_tarihi,birim_ad into projePersonelListe    from personel inner join unvan on unvan.unvan_no=personel.unvan_no 
inner join gorevlendirme on gorevlendirme.personel_no=personel.personel_no inner join proje on proje.proje_no=gorevlendirme.proje_no 
inner join birim on birim.birim_no=personel.birim_no


select * from projePersonelListe

/*20*/