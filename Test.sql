-- 1 Názvy niektorých obcí v tabuľke obec sa opakujú, pretože na Slovensku existujú obce, ktoré majú rovnaký názov. Zistite:
-- koľko je takých obcí (1 dopyt)
-- ktorý názov obce je použitý najviac (1 dopyt)
-- a
SELECT count(nazov) AS pocet
FROM obec o
WHERE (SELECT count(*) from obec ob WHERE o.nazov = ob.nazov) > 1;

-- b
SELECT nazov, count(nazov) AS pocet
FROM obec o
WHERE (SELECT count(*) from obec ob WHERE o.nazov = ob.nazov) > 1
GROUP BY nazov
ORDER BY pocet DESC
LIMIT 2;

-- 2 Koľko okresov sa nachádza v košickom kraji?
SELECT count(*) AS pocet_okresov_kosickeho_kraja
FROM kraj k
         INNER JOIN okres o ON k.id = o.id_kraj
WHERE k.nazov = 'Kosicky kraj';

-- 3 A koľko má košický kraj obcí? Pri tvorbe dopytu vám môže pomôcť informácia, že trenčiansky kraj má spolu 276 obcí.
SELECT count(*) AS pocet_obci_kosickeho_kraja
FROM kraj k
         INNER JOIN okres o ON k.id = o.id_kraj
         INNER JOIN obec ob ON o.id = ob.id_okres
WHERE k.nazov = 'Kosicky kraj';
-- WHERE k.nazov = 'Trenciansky kraj';

-- 4 Zistite, ktorá obec (mesto) bola na Slovensku najväčšia v roku 2012. Pri tvorbe dopytu vám môže pomôcť informácia, že táto obec (mesto) bola najväčšia na Slovensku v rokoch 2009-2012, avšak má v populácii klesajúcu tendenciu. Vo výsledku vypíšte jej názov a počet obyvateľov.
SELECT ob.nazov, p.muzi + p.zeny AS populacia
FROM populacia p,
     obec ob
WHERE p.rok = '2012'
  AND p.id_obec = ob.id
  AND p.id_obec = (SELECT id_obec
                   FROM populacia
                   WHERE muzi + zeny = (SELECT max(muzi + zeny) FROM populacia));

-- 5 Koľko obyvateľov mal okres Sabinov v roku 2012? Pri tvorbe dopytu vám môže pomôcť informácia, že okres Dolný Kubín mal v roku 2010 39553 obyvateľov.
SELECT sum(p.muzi + p.zeny) AS populacia
FROM populacia p,
     obec ob,
     okres ok
WHERE p.rok = '2012'
  AND p.id_obec = ob.id
  AND ob.id_okres = ok.id
  AND ok.nazov = 'Sabinov';

-- 6 Ako sme na tom na Slovensku? Vymierame alebo rastieme? Zobrazte trend vývoja populácie za jednotlivé roky a výsledok zobrazte od najnovších informácií po najstaršie.
SELECT p.rok, sum(p.muzi + p.zeny) AS populacia
FROM populacia p
GROUP BY p.rok
ORDER BY p.rok DESC;

-- 7 Zistite, ktorá obec alebo obce boli najmenšie v okrese Tvrdošín v roku 2011. Pri tvorbe dopytu vám môže pomôcť informácia, že v okrese Ružomberok to bola v roku 2012 obec Potok s počtom obyvateľov 107.
-- SELECT ob.nazov, p.muzi + p.zeny AS populacia FROM populacia p, obec ob, okres ok
-- WHERE p.rok = '2012'
--   AND p.id_obec = ob.id
--   AND ok.id = ob.id_okres
--   AND ok.nazov = 'Ruzomberok'
--   AND p.id_obec = (SELECT id_obec FROM populacia
--     WHERE muzi + zeny = (SELECT min(muzi + zeny) FROM populacia p, obec o, okres ok
--             WHERE p.rok = '2012'
--             AND p.id_obec = ob.id
--             AND ok.id = ob.id_okres
--             AND ok.nazov = 'Ruzomberok')
--   );

SELECT min(p.muzi + p.zeny) AS pocet_obyvatelov, o.nazov
FROM populacia p
         INNER JOIN obec o ON o.id = p.id_obec
         INNER JOIN okres ok ON o.id_okres = ok.id
WHERE ok.nazov = 'Tvrdosin'
  AND p.rok = '2011'
GROUP BY o.nazov
ORDER BY pocet_obyvatelov;

-- 8 Zistite všetky obce (ich názvy), ktoré mali v roku 2010 počet obyvateľov do 5000. Pri tvorbe dopytu vám môže pomôcť informácia, že v roku 2009 bolo týchto obcí o 1 viac ako v roku 2010.
SELECT ob.nazov, p.muzi + p.zeny AS populacia
FROM populacia p,
     obec ob
WHERE p.muzi + p.zeny <= 5000
  AND p.id_obec = ob.id
  AND p.rok = '2010';

-- pomocka na overenie cez pocet tychto obci
SELECT count(*) AS pocet_obci
FROM populacia p,
     obec ob
WHERE p.muzi + p.zeny <= 5000
  AND p.id_obec = ob.id
  AND p.rok = '2010';

-- 9 Zistite 10 obcí s populáciou nad 20000, ktoré mali v roku 2012 najväčší pomer žien voči mužom (viac žien v obci ako mužov). Týchto 10 obcí vypíšte v poradí od najväčšieho pomeru po najmenší. Vo výsledku okrem názvu obce vypíšte aj pomer zaokrúhlený na 4 desatinné miesta. Pri tvorbe dopytu vám môže pomôcť informácia, že v roku 2011 bol tento pomer pre obec Košice  - Juh 1,1673.
SELECT o.nazov, o.id, p.muzi, p.zeny, ROUND(p.zeny * 1.0 / p.muzi, 4) AS pomer
FROM obec o,
     populacia p
WHERE o.id = p.id_obec
  AND p.muzi != '0'
  AND p.rok = '2012'
  AND p.muzi + p.zeny > 20000
ORDER BY p.zeny::float / p.muzi DESC
LIMIT 10;


-- 10 Vypíšte sumárne informácie o stave Slovenska v roku 2012 v podobe tabuľky, ktorá bude obsahovať pre každý kraj informácie o počte obyvateľov, o počte obcí a počte okresov.
SELECT k.nazov, sum(p.muzi + p.zeny) AS pocet_obyvatelov, count(ob.id) AS pocet_obci
FROM kraj k,
     populacia p,
     okres ok,
     obec ob
WHERE k.id = ok.id_kraj
  AND ok.id = ob.id_okres
  AND ob.id = p.id_obec
  AND p.rok = '2012'
GROUP BY k.nazov;

-- 11 To, či vymierame alebo rastieme, sme už zisťovali. Ale ktoré obce sú na tom naozaj zle? Kde by sa nad touto otázkou mali naozaj zamyslieť?
-- Zobrazte obce, ktoré majú klesajúci trend (rozdiel v populácii dvoch posledných rokov je menší ako 0) - vypíšte ich názov, počet obyvateľov v poslednom roku,
-- počet obyvateľov v predchádzajúcom roku a rozdiel v populácii posledného oproti predchádzajúcemu roku.
-- Zoznam utrieďte vzostupne podľa tohto rozdielu od obcí s najmenším prírastkom obyvateľov po najväčší.


-- 12 Zistite počet obcí, ktorých počet obyvateľov v roku 2012 je nižší, ako bol slovenský priemer v danom roku.
SELECT count(o.nazov)
FROM obec o,
     populacia p
WHERE p.muzi + p.zeny < (SELECT sum(muzi + zeny) FROM populacia WHERE rok = '2012') /
                        (SELECT count(id)
                         FROM obec o,
                              populacia p
                         WHERE o.id = p.id_obec
                           AND p.rok = '2012')
  AND o.id = p.id_obec
  AND p.rok = '2012';